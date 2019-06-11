extension Publishers {
    
    /// A publisher that publishes an output to each subscriber exactly once then finishes, or fails immediately without producing any elements.
    ///
    /// If `result` is `.success`, then `Once` waits until it receives a request for at least 1 value before sending the output. If `result` is `.failure`, then `Once` sends the failure immediately upon subscription.
    ///
    /// In contrast with `Just`, a `Once` publisher can terminate with an error instead of sending a value.
    /// In contrast with `Optional`, a `Once` publisher always sends one value (unless it terminates with an error).
    public struct Once<Output, Failure> : Publisher where Failure : Error {
        
        /// The result to deliver to each subscriber.
        public let result: Result<Output, Failure>
        
        /// Creates a publisher that delivers the specified result.
        ///
        /// If the result is `.success`, the `Once` publisher sends the specified output to all subscribers and finishes normally. If the result is `.failure`, then the publisher fails immediately with the specified error.
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ result: Result<Output, Failure>) {
            self.result = result
        }
        
        /// Creates a publisher that sends the specified output to all subscribers and finishes normally.
        ///
        /// - Parameter output: The output to deliver to each subscriber.
        public init(_ output: Output) {
            self.result = .success(output)
        }
        
        /// Creates a publisher that immediately terminates upon subscription with the given failure.
        ///
        /// - Parameter failure: The failure to send when terminating.
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
            let subscription = OnceSubscriptions(self, subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Once {
    
    private final class OnceSubscriptions<S>: Subscription where Output == S.Input, Failure == S.Failure, S : Subscriber {
        
        let isCancelled = Atomic<Bool>(false)
        
        let pub: Publishers.Once<Output, Failure>
        let sub: S
        
        init(_ pub: Publishers.Once<Output, Failure>, _ sub: S) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > 0, !self.isCancelled.load() else {
                return
            }
            
            switch pub.result {
            case .success(let output):
                _ = sub.receive(output)
                sub.receive(completion: .finished)
            case .failure(let error):
                sub.receive(completion: .failure(error))
            }
        }
        
        func cancel() {
            _ = self.isCancelled.exchange(with: true)
        }
    }
}

extension Publishers.Once : Equatable where Output : Equatable, Failure : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Once<Output, Failure>, rhs: Publishers.Once<Output, Failure>) -> Bool {
        return lhs.result == rhs.result
    }
}

extension Publishers.Once where Output : Equatable {
    
    public func contains(_ output: Output) -> Publishers.Once<Bool, Failure> {
        return Publishers.Once(self.result.map { $0 == output })
    }
    
    public func removeDuplicates() -> Publishers.Once<Output, Failure> {
        return self
    }
}

extension Publishers.Once where Output : Comparable {
    
    public func min() -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func max() -> Publishers.Once<Output, Failure> {
        return self
    }
}
