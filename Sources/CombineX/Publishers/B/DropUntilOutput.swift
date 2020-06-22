#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Ignores elements from the upstream publisher until it receives an element from a second publisher.
    ///
    /// This publisher requests a single value from the upstream publisher, and it ignores (drops) all
    /// elements from that publisher until the upstream publisher produces a value. After the `other`
    /// publisher produces an element, this publisher cancels its subscription to the `other` publisher,
    /// and allows events from the `upstream` publisher to pass through.
    ///
    /// After this publisher receives a subscription from the upstream publisher, it passes through
    /// backpressure requests from downstream to the upstream publisher. If the upstream publisher acts
    /// on those requests before the other publisher produces an item, this publisher drops the elements it
    /// receives from the upstream publisher.
    ///
    /// - Parameter publisher: A publisher to monitor for its first emitted element.
    /// - Returns: A publisher that drops elements from the upstream publisher until the `other` publisher produces a value.
    public func drop<P: Publisher>(untilOutputFrom publisher: P) -> Publishers.DropUntilOutput<Self, P> where Failure == P.Failure {
        return .init(upstream: self, other: publisher)
    }
}

extension Publishers.DropUntilOutput: Equatable where Upstream: Equatable, Other: Equatable {}

extension Publishers {
    
    /// A publisher that ignores elements from the upstream publisher until it receives an element from second publisher.
    public struct DropUntilOutput<Upstream: Publisher, Other: Publisher>: Publisher where Upstream.Failure == Other.Failure {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream
        
        /// A publisher to monitor for its first emitted element.
        public let other: Other
        
        /// Creates a publisher that ignores elements from the upstream publisher until it receives an element from another publisher.
        ///
        /// - Parameters:
        ///   - upstream: A publisher to drop elements from while waiting for another publisher to emit elements.
        ///   - other: A publisher to monitor for its first emitted element.
        public init(upstream: Upstream, other: Other) {
            self.upstream = upstream
            self.other = other
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, Other.Failure == S.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.DropUntilOutput {

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

        typealias Pub = Publishers.DropUntilOutput<Upstream, Other>
        typealias Sub = S

        let lock = Lock()
        let sub: Sub
        
        var stopDropping = false
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
            
            if self.stopDropping {
                self.lock.unlock()
                return self.sub.receive(input)
            }
            
            self.lock.unlock()
            return .max(1)
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
            self.lock.withLock {
                self.stopDropping = true
            }
        }
        
        func childReceive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion)
        }

        var description: String {
            return "DropUntilOutput"
        }

        var debugDescription: String {
            return "DropUntilOutput"
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
