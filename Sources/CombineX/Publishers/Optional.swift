extension Publishers {
    
    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// If `result` is `.success`, and the value is non-nil, then `Optional` waits until receiving a request for at least 1 value before sending the output. If `result` is `.failure`, then `Optional` sends the failure immediately upon subscription. If `result` is `.success` and the value is nil, then `Optional` sends `.finished` immediately upon subscription.
    ///
    /// In contrast with `Just`, an `Optional` publisher can send an error.
    /// In contrast with `Once`, an `Optional` publisher can send zero values and finish normally, or send zero values and fail with an error.
    public struct Optional<Output, Failure> : Publisher where Failure : Error {
        
        /// The result to deliver to each subscriber.
        public let result: Result<Output?, Failure>
        
        /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
        ///
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output?, Failure>) {
            self.result = result
        }
        
        public init(_ output: Output?) {
            self.result = .success(output)
        }
        
        public init(_ failure: Failure) {
            self.result = .failure(failure)
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
            let subscription = Inner(result: self.result, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Optional {
    
    private final class Inner<S>:
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S : Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        let state = Atomic<SubscriptionState>(value: .waiting)
        let result: Result<Output?, Failure>
        
        var sub: S?
        
        init(result: Result<Output?, Failure>, sub: S) {
            self.result = result
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                
                guard demand > 0 else {
                    fatalError("trying to request '<= 0' values from Once")
                }
                
                switch self.result {
                case .success(let optional):
                    if let output = optional {
                        _ = self.sub?.receive(output)
                    }
                    self.sub?.receive(completion: .finished)
                case .failure(let error):
                    self.sub?.receive(completion: .failure(error))
                }
                
                self.state.store(.finished)
                self.sub = nil
            }
        }
        
        func cancel() {
            self.state.store(.finished)
            self.sub = nil
        }
        
        var description: String {
            return "Optinal"
        }
        
        var debugDescription: String {
            return "Optinal"
        }
    }
}
