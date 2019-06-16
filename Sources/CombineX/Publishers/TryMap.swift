extension Publisher {
    
    /// Transforms all elements from the upstream publisher with a provided error-throwing closure.
    ///
    /// If the `transform` closure throws an error, the publisher fails with the thrown error.
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func tryMap<T>(_ transform: @escaping (Self.Output) throws -> T) -> Publishers.TryMap<Self, T> {
        return Publishers.TryMap<Self, T>(upstream: self, transform: transform)
    }
}

extension Publishers {
    
    /// A publisher that transforms all elements from the upstream publisher with a provided error-throwing closure.
    public struct TryMap<Upstream, Output> : Publisher where Upstream : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The error-throwing closure that transforms elements from the upstream publisher.
        public let transform: (Upstream.Output) throws -> Output
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.TryMap<Upstream, Output>.Failure {
            let subscription = TryMapSubscription(pub: self, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.TryMap {
    
    private final class TryMapSubscription<S>:
        CustomSubscription<Publishers.TryMap<Upstream, Output>, S>,
        Subscriber
        where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        private let subscription = Atomic<Subscription?>(value: nil)
        
        override init(pub: Pub, sub: Sub) {
            super.init(pub: pub, sub: sub)
            self.pub.upstream.subscribe(self)
        }
        
        override func request(_ demand: Subscribers.Demand) {
            self.subscription.load()?.request(demand)
        }
        
        override func cancel() {
            self.subscription.load()?.cancel()
        }
        
        func receive(subscription: Subscription) {
            if Atomic.ifNil(self.subscription, store: subscription) {
                self.sub.receive(subscription: self)
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            do {
                return self.sub.receive(try self.pub.transform(input))
            } catch {
                self.sub.receive(completion: .failure(error))
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            switch completion {
            case .finished:
                self.sub.receive(completion: .finished)
            case .failure(let e):
                self.sub.receive(completion: .failure(e))
            }
        }
    }
}
