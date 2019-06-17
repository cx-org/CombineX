import Foundation

extension Publishers {
    
    /// A publisher that emits an output to each subscriber just once, and then finishes.
    ///
    /// You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Catch`.
    ///
    /// In contrast with `Publishers.Once`, a `Just` publisher cannot fail with an error.
    /// In contrast with `Publishers.Optional`, a `Just` publisher always produces a value.
    public struct Just<Output> : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never
        
        /// The one element that the publisher emits.
        public let output: Output
        
        /// Initializes a publisher that emits the specified output just once.
        ///
        /// - Parameter output: The one element that the publisher emits.
        public init(_ output: Output) {
            self.output = output
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S)
        where S : Subscriber, S.Input == Output, S.Failure == Never
        {
            let subscription = JustSubscription(just: self.output, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Just {
    
    private final class JustSubscription<S>:
        Subscription
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Never
    {
        
        let state = Atomic<SubscriptionState>(value: .waiting)
        let just: Output
        
        var sub: S?
        
        init(just: Output, sub: S) {
            self.just = just
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                guard demand > 0 else {
                    fatalError("trying to request '<= 0' values from Just")
                }
                
                _ = self.sub?.receive(just)
                self.sub?.receive(completion: .finished)
                self.state.store(.finished)
            }
        }
        
        func cancel() {
            self.state.store(.finished)
            self.sub = nil
        }
    }
}

extension Publishers.Just : Equatable where Output : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Just<Output>, rhs: Publishers.Just<Output>) -> Bool {
        return lhs.output == rhs.output
    }
}

extension Publishers.Just where Output : Comparable {
    
    public func min() -> Publishers.Just<Output> {
        return self
    }
    
    public func max() -> Publishers.Just<Output> {
        return self
    }
}

extension Publishers.Just where Output : Equatable {
    
    public func contains(_ output: Output) -> Publishers.Just<Bool> {
        return Publishers.Just(self.output == output)
    }
    
    public func removeDuplicates() -> Publishers.Just<Output> {
        return self
    }
}
