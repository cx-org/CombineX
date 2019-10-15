import CombineX
import Foundation

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

extension NotificationCenter.CX {
    
    /// A publisher that emits elements when broadcasting notifications.
    public struct NotificationPublisher : CombineX.Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Notification

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never

        /// The notification center this publisher uses as a source.
        public let center: NotificationCenter

        /// The name of notifications published by this publisher.
        public let name: Notification.Name

        /// The object posting the named notfication.
        public let object: AnyObject?

        /// Creates a publisher that emits events when broadcasting notifications.
        ///
        /// - Parameters:
        ///   - center: The notification center to publish notifications for.
        ///   - name: The name of the notification to publish.
        ///   - object: The object posting the named notfication. If `nil`, the publisher emits elements for any object producing a notification with the given name.
        public init(center: NotificationCenter, name: Notification.Name, object: AnyObject? = nil) {
            self.center = center
            self.name = name
            self.object = object
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == NotificationPublisher.Failure, S.Input == NotificationPublisher.Output {
            let subject = PassthroughSubject<Output, Failure>()
            let observer = self.center.addObserver(forName: self.name, object: self.object, queue: nil) { (n) in
                subject.send(n)
            }
            subject
                .handleEvents(receiveCancel: {
                    self.center.removeObserver(observer)
                })
                .receive(subscriber: subscriber)
            
        }
    }
}
