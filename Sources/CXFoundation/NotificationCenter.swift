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

// Adapted from the original file:
// https://github.com/apple/swift/blob/main/stdlib/public/Darwin/Foundation/Publishers%2BNotificationCenter.swift

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

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
        
        public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
            subscriber.receive(subscription: Notification.Subscription(center, name, object, subscriber))
        }
    }
}

extension CXWrappers.NotificationCenter.Publisher: Equatable {
    public static func == (
        lhs: CXWrappers.NotificationCenter.Publisher,
        rhs: CXWrappers.NotificationCenter.Publisher
    ) -> Bool {
        return lhs.center === rhs.center
            && lhs.name == rhs.name
            && lhs.object === rhs.object
    }
}

// MARK: - Subscription

private extension Notification {
    
    final class Subscription<S: Subscriber>: CombineX.Subscription, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible
            where
                S.Input == Notification
    {
        private let lock = Lock()
        
        // This lock can only be held for the duration of downstream callouts
        private let downstreamLock = RecursiveLock()

        private var demand: Subscribers.Demand      // GuardedBy(lock)
        private var center: NotificationCenter?     // GuardedBy(lock)
        private let name: Notification.Name         // Stored only for debug info
        private var object: AnyObject?              // Stored only for debug info
        private var observation: AnyObject?         // GuardedBy(lock)
        var description: String { return "NotificationCenter Observer" }
        var customMirror: Mirror {
            lock.lock()
            defer { lock.unlock() }
            return Mirror(self, children: [
                "center": center as Any,
                "name": name as Any,
                "object": object as Any,
                "demand": demand
            ])
        }
        var playgroundDescription: Any { return description }

        init(_ center: NotificationCenter,
             _ name: Notification.Name,
             _ object: AnyObject?,
             _ next: S)
        {
            self.demand = .max(0)
            self.center = center
            self.name = name
            self.object = object

            self.observation = center.addObserver(
                forName: name,
                object: object,
                queue: nil
            ) { [weak self] note in
                guard let self = self else { return }

                self.lock.lock()
                guard self.observation != nil else {
                    self.lock.unlock()
                    return
                }

                let demand = self.demand
                if demand > 0 {
                    self.demand -= 1
                }
                self.lock.unlock()

                if demand > 0 {
                    self.downstreamLock.lock()
                    let additionalDemand = next.receive(note)
                    self.downstreamLock.unlock()

                    if additionalDemand > 0 {
                        self.lock.lock()
                        self.demand += additionalDemand
                        self.lock.unlock()
                    }
                } else {
                    // Drop it on the floor
                }
            }
        }

        deinit {
            lock.cleanupLock()
            downstreamLock.cleanupLock()
        }

        func request(_ d: Subscribers.Demand) {
            lock.lock()
            demand += d
            lock.unlock()
        }

        func cancel() {
            lock.lock()
            guard let center = self.center,
                let observation = self.observation else {
                    lock.unlock()
                    return
            }
            self.center = nil
            self.observation = nil
            self.object = nil
            lock.unlock()

            center.removeObserver(observation)
        }
    }
}
