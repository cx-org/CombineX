#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Republishes elements until another publisher emits an element.
    ///
    /// After the second publisher publishes an element, the publisher returned by this method finishes.
    ///
    /// - Parameter publisher: A second publisher.
    /// - Returns: A publisher that republishes elements until the second publisher publishes an element.
    public func prefix<P: Publisher>(untilOutputFrom publisher: P) -> Publishers.PrefixUntilOutput<Self, P> {
        return .init(upstream: self, other: publisher)
    }
}

extension Publishers {
    
    public struct PrefixUntilOutput<Upstream: Publisher, Other: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// Another publisher, whose first output causes this publisher to finish.
        public let other: Other
        
        public init(upstream: Upstream, other: Other) {
            self.upstream = upstream
            self.other = other
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.PrefixUntilOutput {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.PrefixUntilOutput<Upstream, Other>
        typealias Sub = S
        
        let lock = Lock()
        let sub: Sub
        
        var state = RelayState.waiting
        
        var child: Child?
        
        init(pub: Pub, sub: Sub) {
            self.sub = sub
            
            let child = Child(parent: self)
            pub.other.subscribe(child)
            
            self.child = child
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.withLockGet(self.state.subscription)?.request(demand)
        }
        
        func cancel() {
            self.lock.lock()
            guard let subscription = self.state.complete() else {
                self.lock.unlock()
                return
            }
            
            let child = self.child
            self.child = nil
            self.lock.unlock()
            
            subscription.cancel()
            child?.cancel()
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            self.lock.unlock()
            return self.sub.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            guard let subscription = self.state.complete() else {
                self.lock.unlock()
                return
            }
            
            let child = self.child
            self.child = nil
            self.lock.unlock()
            
            subscription.cancel()
            child?.cancel()
            
            self.sub.receive(completion: completion)
        }

        func childReceive(_ input: Other.Output) {
            self.receive(completion: .finished)
        }
        
        func childReceive(completion: Subscribers.Completion<Other.Failure>) {
            // noop
        }
        
        var description: String {
            return "PrefixUntilOutput"
        }
        
        var debugDescription: String {
            return "PrefixUntilOutput"
        }
        
        final class Child: Subscriber {
            typealias Input = Other.Output
            typealias Failure = Other.Failure
            
            let subscription = LockedAtomic<Subscription?>(nil)
            let parent: Inner
            
            init(parent: Inner) {
                self.parent = parent
            }
            
            func receive(subscription: Subscription) {
                guard self.subscription.setIfNil(subscription) else {
                    subscription.cancel()
                    return
                }
                subscription.request(.max(1))
            }
            
            func receive(_ input: Input) -> Subscribers.Demand {
                guard let subscription = self.subscription.exchange(nil) else {
                    return .none
                }
                subscription.cancel()
                
                self.parent.childReceive(input)
                return .none
            }
            
            func receive(completion: Subscribers.Completion<Failure>) {
                guard let subscription = self.subscription.exchange(nil) else {
                    return
                }
                subscription.cancel()
                self.parent.childReceive(completion: completion)
            }
            
            func cancel() {
                self.subscription.exchange(nil)?.cancel()
            }
        }
    }
}
