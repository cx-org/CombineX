#if canImport(Foundation) && canImport(Combine)
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXWrapper where Base: NotificationCenter {
    
    /// Returns a publisher that emits events when broadcasting notifications.
    ///
    /// - Parameters:
    ///   - name: The name of the notification to publish.
    ///   - object: The object posting the named notfication. If `nil`, the publisher emits elements for any object producing a notification with the given name.
    /// - Returns: A publisher that emits events when broadcasting notifications.
    public func publisher(for name: Notification.Name, object: AnyObject? = nil) -> NotificationCenter.CX.NotificationPublisher {
        return .init(center: self.base, name: name, object: object)
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension NotificationCenter.CX {
    
    /// A publisher that emits elements when broadcasting notifications.
    public typealias NotificationPublisher = NotificationCenter.Publisher
}

#endif
