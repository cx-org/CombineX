extension Publisher {
    
    /// Republishes elements until another publisher emits an element.
    ///
    /// After the second publisher publishes an element, the publisher returned by this method finishes.
    ///
    /// - Parameter publisher: A second publisher.
    /// - Returns: A publisher that republishes elements until the second publisher publishes an element.
    public func prefix<P>(untilOutputFrom publisher: P) -> Publishers.PrefixUntilOutput<Self, P> where P : Publisher {
        return .init(upstream: self, other: publisher)
    }
}

extension Publishers {
    
    public struct PrefixUntilOutput<Upstream, Other> : Publisher where Upstream : Publisher, Other : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// Another publisher, whose first output causes this publisher to finish.
        public let other: Other
        
        public init(upstream: Upstream, other: Other) {
            self.upstream = upstream
            self.other = other
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.PrefixUntilOutput {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.PrefixUntilOutput<Upstream, Other>
        typealias Sub = S
        
        let lock = Lock()
        
        let sub: Sub
        
        var state = RelayState.waiting
        
        var other: Cancellable!
        
        init(pub: Pub, sub: Sub) {
            self.sub = sub
            
            self.other = pub.other.sink(receiveCompletion: { [weak self] (c) in
                guard let self = self else { return }
                self.other.cancel()
            }, receiveValue: { [weak self] o in
                guard let self = self else { return }
                self.other.cancel()
                
                guard let subscription = self.lock.withLockGet(self.state.finish()) else {
                    return
                }
                
                subscription.cancel()
                self.sub.receive(completion: .finished)
            })
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.withLockGet(self.state.subscription)?.request(demand)
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.finish())?.cancel()
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
            guard let subscription = self.lock.withLockGet(self.state.finish()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "PrefixUntilOutput"
        }
        
        var debugDescription: String {
            return "PrefixUntilOutput"
        }
    }
}
