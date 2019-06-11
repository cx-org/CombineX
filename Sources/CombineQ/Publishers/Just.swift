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
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, S.Failure == Publishers.Just<Output>.Failure {
            let subscription = JustSubscription(self, subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Just {
    
    private final class JustSubscription<S>: Subscription where Output == S.Input, S : Subscriber, S.Failure == Publishers.Just<Output>.Failure {
        
        let isCancelled = Atomic<Bool>(false)
        
        let pub: Publishers.Just<Output>
        let sub: S
        
        init(_ pub: Publishers.Just<Output>, _ sub: S) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > 0, !self.isCancelled.load() else {
                return
            }
            _ = self.sub.receive(self.pub.output)
            self.sub.receive(completion: .finished)
        }
        
        func cancel() {
            _ = self.isCancelled.exchange(with: true)
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
