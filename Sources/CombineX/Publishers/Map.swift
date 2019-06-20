import Foundation

extension Publisher {
    
    /// Transforms all elements from the upstream publisher with a provided closure.
    ///
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func map<T>(_ transform: @escaping (Self.Output) -> T) -> Publishers.Map<Self, T> {
        return Publishers.Map<Self, T>(upstream: self, transform: transform)
    }
}

extension Publishers {
    
    /// A publisher that transforms all elements from the upstream publisher with a provided closure.
    public struct Map<Upstream, Output> : Publisher where Upstream : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that transforms elements from the upstream publisher.
        public let transform: (Upstream.Output) -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, Upstream.Failure == S.Failure {
            let subscription = MapSubscription(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.Map {
    
    private final class MapSubscription<S>:
        Subscription,
        Subscriber
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Map<Upstream, Output>
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
            
            if let transform = self.pub?.transform, let demand = self.sub?.receive(transform(input)) {
                return demand
            }
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            if let subscription = self.state.finishIfSubscribing() {
                subscription.cancel()
                self.sub?.receive(completion: completion)
                self.pub = nil
                self.sub = nil
            }
        }
    }
}
