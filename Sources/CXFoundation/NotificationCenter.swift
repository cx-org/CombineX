import CombineX
import CXUtility
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    public final class NotificationCenter: NSObject<Foundation.NotificationCenter> {}
}

extension NotificationCenter {
    
    public typealias CX = CXWrappers.NotificationCenter
    
    public var cx: CXWrappers.NotificationCenter {
        return CXWrappers.NotificationCenter(wrapping: self)
    }
}

extension CXWrappers.NotificationCenter {
    
    /// Returns a publisher that emits events when broadcasting notifications.
    ///
    /// - Parameters:
    ///   - name: The name of the notification to publish.
    ///   - object: The object posting the named notfication. If `nil`, the publisher emits elements for any object producing a notification with the given name.
    /// - Returns: A publisher that emits events when broadcasting notifications.
    public func publisher(for name: Notification.Name, object: AnyObject? = nil) -> CXWrappers.NotificationCenter.Publisher {
        return .init(center: self.base, name: name, object: object)
    }
}

extension CXWrappers.NotificationCenter {
    
    /// A publisher that emits elements when broadcasting notifications.
    public struct Publisher: CombineX.Publisher {
        
        public typealias Output = Notification
        
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
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Publisher.Failure, S.Input == Publisher.Output {
            let subscription = Notification.Subscription(center: center, name: name, object: object, downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension CXWrappers.NotificationCenter.Publisher: Equatable {
    
    public static func == (lhs: CXWrappers.NotificationCenter.Publisher, rhs: CXWrappers.NotificationCenter.Publisher) -> Bool {
        return lhs.center == rhs.center &&
            lhs.name == rhs.name &&
            lhs.object === rhs.object
    }
}

// MARK: - Subscription

private extension Notification {
    
    final class Subscription<Downstream: Subscriber>: CombineX.Subscription where Downstream.Input == Notification, Downstream.Failure == Never {
        
        let lock = Lock()
        
        let downstreamLock = Lock(recursive: true)
        
        var demand = Subscribers.Demand.none
        
        var center: NotificationCenter?
        
        let name: Name
        
        var object: AnyObject?
        
        var observation: AnyObject?
        
        init(center: NotificationCenter, name: Notification.Name, object: AnyObject?, downstream: Downstream) {
            self.center = center
            self.name = name
            self.object = object
            self.observation = center.addObserver(forName: name, object: object, queue: nil) { [unowned self] in
                self.didReceiveNotification($0, downstream: downstream)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.withLock {
                self.demand += demand
            }
        }
        
        func cancel() {
            lock.lock()
            guard let center = self.center, let observation = self.observation else {
                lock.unlock()
                return
            }
            self.center = nil
            self.object = nil
            self.observation = nil
            lock.unlock()
            
            center.removeObserver(observation)
        }
        
        func didReceiveNotification(_ notification: Notification, downstream: Downstream) {
            lock.lock()
            guard demand > 0 else {
                lock.unlock()
                return
            }
            demand -= 1
            lock.unlock()
            
            let newDemand = downstreamLock.withLock {
                downstream.receive(notification)
            }
            
            lock.withLock {
                self.demand += newDemand
            }
        }
    }
}
