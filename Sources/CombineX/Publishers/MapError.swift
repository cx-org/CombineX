extension Publisher {
    
    /// Converts any failure from the upstream publisher into a new error.
    ///
    /// Until the upstream publisher finishes normally or fails with an error, the returned publisher republishes all the elements it receives.
    ///
    /// - Parameter transform: A closure that takes the upstream failure as a parameter and returns a new error for the publisher to terminate with.
    /// - Returns: A publisher that replaces any upstream failure with a new error produced by the `transform` closure.
    public func mapError<E>(_ transform: @escaping (Self.Failure) -> E) -> Publishers.MapError<Self, E> where E : Error {
        return Publishers.MapError(upstream: self, transform)
    }
}

extension Publishers {
    
    /// A publisher that converts any failure from the upstream publisher into a new error.
    public struct MapError<Upstream, Failure> : Publisher where Upstream : Publisher, Failure : Error {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that converts the upstream failure into a new error.
        public let transform: (Upstream.Failure) -> Failure
        
        public init(upstream: Upstream, _ map: @escaping (Upstream.Failure) -> Failure) {
            self.upstream = upstream
            self.transform = map
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Failure == S.Failure, S : Subscriber, Upstream.Output == S.Input {
            let subscription = MapErrorSubscription(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.MapError {
    
    private final class MapErrorSubscription<S>:
        Subscription,
        Subscriber
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.MapError<Upstream, S.Failure>
        typealias Sub = S
        
        let state = Atomic<RelaySubscriberState>(value: .waiting)
        
        var pub: Pub?
        var sub: Sub?
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.state.subscription?.request(demand)
        }
        
        func cancel() {
            self.state.finishIfSubscribing()?.cancel()

            self.pub = nil
            self.sub = nil
        }
        
        func receive(subscription: Subscription) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(subscription)) {
                self.sub?.receive(subscription: self)
            } else {
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.state.isSubscribing else {
                return .none
            }
            
            return self.sub?.receive(input) ?? .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            if let subscription = self.state.finishIfSubscribing() {
                subscription.cancel()
                
                guard let transform = self.pub?.transform else {
                    return
                }
                
                switch completion {
                case .finished:
                    self.sub?.receive(completion: .finished)
                case .failure(let e):
                    self.sub?.receive(completion: .failure(transform(e)))
                }
                
                self.pub = nil
                self.sub = nil
            }
        }
    }
}
