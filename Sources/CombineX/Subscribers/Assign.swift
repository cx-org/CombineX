#if !COCOAPODS
import CXUtility
#endif

extension Publisher where Failure == Never {
    
    /// Assigns each element from a Publisher to a property on an object.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property to assign.
    ///   - object: The object on which to assign the value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable {
        let assign = Subscribers.Assign(object: object, keyPath: keyPath)
        self.subscribe(assign)
        return AnyCancellable(assign)
    }
}

extension Subscribers {
    
    public final class Assign<Root, Input>: Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
        
        public typealias Failure = Never
        
        public private(set) final var object: Root?
        
        public final let keyPath: ReferenceWritableKeyPath<Root, Input>
        
        public final var description: String {
            return "Assign \(Root.self)"
        }
        
        public final var customMirror: Mirror {
            return Mirror(self, children: [
                "object": self.object as Any,
                "keyPath": self.keyPath,
                "upstreamSubscription": self.subscription as Any
            ])
        }
        
        public final var playgroundDescription: Any {
            return self.description
        }
        
        private let lock = Lock()
        private var subscription: Subscription?
        
        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        public final func receive(subscription: Subscription) {
            self.lock.lock()
            if self.subscription == nil {
                self.subscription = subscription
                self.lock.unlock()
                subscription.request(.unlimited)
            } else {
                self.lock.unlock()
                subscription.cancel()
            }
        }
        
        public final func receive(_ value: Input) -> Subscribers.Demand {
            self.lock.lock()
            if self.subscription == nil {
                self.lock.unlock()
            } else {
                let obj = self.object
                self.lock.unlock()
                
                obj?[keyPath: self.keyPath] = value
            }
            return .none
        }
        
        public final func receive(completion: Subscribers.Completion<Never>) {
            lock.lock()
            guard self.subscription != nil else {
                lock.unlock()
                return
            }
            lockedTerminate()
        }
        
        public final func cancel() {
            self.lock.lock()
            guard let subscription = self.subscription else {
                self.lock.unlock()
                return
            }
            lockedTerminate()
            subscription.cancel()
        }
        
        private func lockedTerminate() {
            self.subscription = nil
            self.object = nil
            self.lock.unlock()
        }
    }
}
