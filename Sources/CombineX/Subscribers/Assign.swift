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
    
    final public class Assign<Root, Input> : Subscriber, Cancellable, CustomStringConvertible, CustomReflectable, CustomPlaygroundDisplayConvertible {
        
        public typealias Failure = Never
        
        final public private(set) var object: Root?
        
        final public let keyPath: ReferenceWritableKeyPath<Root, Input>
        
        final public var description: String {
            return "Assign \(Root.self)"
        }
        
        final public var customMirror: Mirror {
            return Mirror(self, children: [
                "object": self.object as Any,
                "keyPath": self.keyPath,
                "upstreamSubscription": self.subscription as Any
            ])
        }
        
        final public var playgroundDescription: Any {
            return self.description
        }
        
        private let lock = Lock()
        private var subscription: Subscription?
        
        public init(object: Root, keyPath: ReferenceWritableKeyPath<Root, Input>) {
            self.object = object
            self.keyPath = keyPath
        }
        
        final public func receive(subscription: Subscription) {
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
        
        final public func receive(_ value: Input) -> Subscribers.Demand {
            self.lock.lock()
            if self.subscription.isNil {
                self.lock.unlock()
            } else {
                let obj = self.object
                self.lock.unlock()
                
                obj?[keyPath: self.keyPath] = value
            }
            return .none
        }
        
        final public func receive(completion: Subscribers.Completion<Never>) {
            self.cancel()
        }
        
        final public func cancel() {
            self.lock.lock()
            guard let subscription = self.subscription else {
                self.lock.unlock()
                return
            }
            
            self.subscription = nil
            self.object = nil
            self.lock.unlock()
            
            subscription.cancel()
        }
        
    }
}
