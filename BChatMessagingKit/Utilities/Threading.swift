import Foundation

internal enum Threading {

    internal static let jobQueue = DispatchQueue(label: "BChatMessagingKit.jobQueue", qos: .userInitiated)
    
    internal static let pollerQueue = DispatchQueue(label: "BChatMessagingKit.pollerQueue")
}
