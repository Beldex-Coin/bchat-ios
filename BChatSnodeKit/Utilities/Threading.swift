import Foundation

internal enum Threading {

    internal static let workQueue = DispatchQueue(label: "BChatSnodeKit.workQueue", qos: .userInitiated) // It's important that this is a serial queue
}
