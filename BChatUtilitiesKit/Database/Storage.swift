import PromiseKit
import YapDatabase
import GRDB

// Some important notes about YapDatabase:
//
// • Connections are thread-safe.
// • Executing a write transaction from within a write transaction is NOT allowed.

@objc(LKStorage)
public final class Storage : NSObject {
    public static let serialQueue = DispatchQueue(label: "Storage.serialQueue", qos: .userInitiated)

    private static var owsStorage: OWSPrimaryStorageProtocol { SNUtilitiesKitConfiguration.shared.owsPrimaryStorage }
    
    @objc public static let shared = Storage()
    
    fileprivate var dbWriter: DatabaseWriter?
    private static let writeWarningThreadshold: TimeInterval = 3
    
    /// This property gets set the first time we successfully read from the database
    public private(set) var hasSuccessfullyRead: Bool = false
    
    /// This property gets set the first time we successfully write to the database
    public private(set) var hasSuccessfullyWritten: Bool = false

    // MARK: Reading

    // Some important points regarding reading from the database:
    //
    // • Background threads should use `OWSPrimaryStorage`'s `dbReadConnection`, whereas the main thread should use `OWSPrimaryStorage`'s `uiDatabaseConnection` (see the `YapDatabaseConnectionPool` documentation for more information).
    // • Multiple read transactions can safely be executed at the same time.

    @objc(readWithBlock:)
    public static func read(with block: @escaping (YapDatabaseReadTransaction) -> Void) {
        owsStorage.dbReadConnection.read(block)
    }

    // MARK: Writing

    // Some important points regarding writing to the database:
    //
    // • There can only be a single write transaction per database at any one time, so all write transactions must use `OWSPrimaryStorage`'s `dbReadWriteConnection`.
    // • Executing a write transaction from within a write transaction causes a deadlock and must be avoided.

    @discardableResult
    @objc(writeWithBlock:)
    public static func objc_write(with block: @escaping (YapDatabaseReadWriteTransaction) -> Void) -> AnyPromise {
        return AnyPromise.from(write(with: block) { })
    }

    @discardableResult
    public static func write(with block: @escaping (YapDatabaseReadWriteTransaction) -> Void) -> Promise<Void> {
        return write(with: block) { }
    }

    @discardableResult
    @objc(writeWithBlock:completion:)
    public static func objc_write(with block: @escaping (YapDatabaseReadWriteTransaction) -> Void, completion: @escaping () -> Void) -> AnyPromise {
        return AnyPromise.from(write(with: block, completion: completion))
    }

    @discardableResult
    public static func write(with block: @escaping (YapDatabaseReadWriteTransaction) -> Void, completion: @escaping () -> Void) -> Promise<Void> {
        let (promise, seal) = Promise<Void>.pending()
        serialQueue.async {
            owsStorage.dbReadWriteConnection.readWrite { transaction in
                transaction.addCompletionQueue(DispatchQueue.main, completionBlock: completion)
                block(transaction)
            }
            seal.fulfill(())
        }
        return promise
    }

    /// Blocks the calling thread until the write has finished.
    @objc(writeSyncWithBlock:)
    public static func writeSync(with block: @escaping (YapDatabaseReadWriteTransaction) -> Void) {
        try! write(with: block, completion: { }).wait() // The promise returned by write(with:completion:) never rejects
    }
}

extension Storage {
    
    private enum Action {
        case read
        case write
        case logIfSlow
    }
    
    private typealias CallInfo = (storage: Storage?, actions: [Action], file: String, function: String, line: Int)
    
//    @discardableResult public func read<T>(fileName: String = #file,
//                                    functionName: String = #function,
//                                    lineNumber: Int = #line,
//                                    _ value: @escaping (Database) throws -> T?) -> T? {
//        //guard let dbWriter: DatabaseWriter = dbWriter else { return nil }
//        
//        let dbWriter: DatabaseWriter// = dbWriter
//        let info: CallInfo = { [weak self] in (self, [.read], fileName, functionName, lineNumber) }()
//        do {
//            return try dbWriter.read(Storage.perform(info: info, updates: value))
//        } catch { return Storage.logIfNeeded(error, isWrite: false) }
//    }
    
    private static func perform<T>(
        info: CallInfo,
        updates: @escaping (Database) throws -> T
    ) -> (Database) throws -> T {
        return { db in
//            let start: CFTimeInterval = CACurrentMediaTime()
//            let actionName: String = (info.actions.contains(.write) ? "write" : "read")
            let fileName: String = (info.file.components(separatedBy: "/").last.map { " \($0):\(info.line)" } ?? "")
            let timeout: Timer? = {
                //guard info.actions.contains(.logIfSlow) else { return nil }
                
                return Timer.scheduledTimerOnMainThread(withTimeInterval: Storage.writeWarningThreadshold, repeats: false) {
                    $0.invalidate()
                    
                    // Don't want to log on the main thread as to avoid confusion when debugging issues
                    DispatchQueue.global(qos: .default).async {
                        //SNLog("[Storage\(fileName)] Slow \(actionName) taking longer than \(Storage.writeWarningThreadshold, format: ".2", omitZeroDecimal: true)s - \(info.function)")
                        debugPrint("[Storage\(fileName)]")
                    }
                }
            }()
            
            // If we timed out and are logging slow actions then log the actual duration to help us
            // prioritise performance issues
            defer {
                if timeout != nil && timeout?.isValid == false {
                    //let end: CFTimeInterval = CACurrentMediaTime()
                    
                    DispatchQueue.global(qos: .default).async {
                        //SNLog("[Storage\(fileName)] Slow \(actionName) completed after \(end - start, format: ".2", omitZeroDecimal: true)s")
                        
                        debugPrint("[Storage\(fileName)]")
                    }
                }
                
                timeout?.invalidate()
            }
            
            // Get the result
            let result: T = try updates(db)
            
            // Update the state flags
            switch info.actions {
                case [.write], [.write, .logIfSlow]: info.storage?.hasSuccessfullyWritten = true
                case [.read], [.read, .logIfSlow]: info.storage?.hasSuccessfullyRead = true
                default: break
            }
            
            return result
        }
    }
 
    private static func logIfNeeded(_ error: Error, isWrite: Bool) {
        switch error {
            case DatabaseError.SQLITE_ABORT:
                let message: String = ((error as? DatabaseError)?.message ?? "Unknown")
                SNLog("[Storage] Database \(isWrite ? "write" : "read") failed due to error: \(message)")
                
            default: break
        }
    }
    
    private static func logIfNeeded<T>(_ error: Error, isWrite: Bool) -> T? {
        logIfNeeded(error, isWrite: isWrite)
        return nil
    }
}
