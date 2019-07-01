extension Publisher {
    
    /// Transforms all elements from the upstream publisher with a provided closure.
    ///
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func map<T>(_ transform: @escaping (Self.Output) -> T) -> Publishers.Map<Self, T> {
        return .init(upstream: self, transform: transform)
    }
}

extension Publishers.Map {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.Map<Upstream, T> {
        let newTransform: (Upstream.Output) -> T = {
            transform(self.transform($0))
        }
        return self.upstream.map(newTransform)
    }
    
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T> {
        let newTransform: (Upstream.Output) throws -> T = {
            try transform(self.transform($0))
        }
        return self.upstream.tryMap(newTransform)
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
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.Map {
    
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
        
        typealias Pub = Publishers.Map<Upstream, Output>
        typealias Sub = S

        let state = Atomic<RelayState>(value: .waiting)
        
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
            self.state.finishIfRelaying()?.cancel()
            
            self.pub = nil
            self.sub = nil
        }
        
        func receive(subscription: Subscription) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .relaying(subscription)) {
                self.sub?.receive(subscription: self)
            } else {
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.state.isRelaying else {
                return .none
            }
            
            guard let pub = self.pub, let sub = self.sub else {
                return .none
            }
            
            return sub.receive(pub.transform(input))
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            if let subscription = self.state.finishIfRelaying() {
                subscription.cancel()
                self.sub?.receive(completion: completion)
                self.pub = nil
                self.sub = nil
            }
        }
        
        var description: String {
            return "Map"
        }
        
        var debugDescription: String {
            return "Map"
        }
    }
}
