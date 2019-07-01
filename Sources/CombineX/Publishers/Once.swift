extension Publishers.Once {
    
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return .init(self.result.map(predicate))
    }
    
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return .init(self.result.tryMap(predicate))
    }
    
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        return .init(self.result.map(transform))
    }
    
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        return .init(self.result.tryMap(transform))
    }
    
    public func collect() -> Publishers.Once<[Output], Failure> {
        return .init(self.result.map({ [$0] }))
    }
    
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func contains(where predicate: (Output) -> Bool) -> Publishers.Once<Bool, Failure> {
        return self.allSatisfy(predicate)
    }
    
    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return self.tryAllSatisfy(predicate)
    }
    
    public func count() -> Publishers.Once<Int, Failure> {
        return .init(self.result.map { _ in 1 })
    }
    
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        precondition(count >= 0)
        
        if count == 0 {
            return self.compactMap { $0 }
        } else {
            return .init(self.result.map { _ in nil })
        }
    }
    
    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.compactMap {
            if predicate($0) {
                return nil
            } else {
                return $0
            }
        }
    }
    
    public func tryDrop(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryCompactMap {
            if try predicate($0) {
                return nil
            } else {
                return $0
            }
        }
    }
    
    public func first() -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.compactMap {
            if predicate($0) {
                return $0
            } else {
                return nil
            }
        }
    }
    
    public func tryFirst(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryCompactMap {
            if try predicate($0) {
                return $0
            } else {
                return nil
            }
        }
    }
    
    public func last() -> Publishers.Once<Output, Failure> {
        return self.first()
    }
    
    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.first(where: predicate)
    }
    
    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFirst(where: predicate)
    }
    
    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self.first(where: isIncluded)
    }
    
    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFirst(where: isIncluded)
    }
    
    public func ignoreOutput() -> Publishers.Empty<Output, Failure> {
        return .init()
    }
    
    public func map<T>(_ transform: (Output) -> T) -> Publishers.Once<T, Failure> {
        return .init(self.result.map(transform))
    }
    
    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error> {
        return .init(self.result.tryMap(transform))
    }
    
    public func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Once<Output, E> where E : Error {
        return .init(self.result.mapError(transform))
    }

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure> {
        return .init(self.result.map {
            nextPartialResult(initialResult, $0)
        })
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return .init(self.result.tryMap {
            try nextPartialResult(initialResult, $0)
        })
    }
    
    public func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        if index == 0 {
            return .init(self.result.map { $0 })
        } else {
            return .init(nil)
        }
    }
    
    public func output<R>(in range: R) -> Publishers.Optional<Output, Failure> where R : RangeExpression, R.Bound == Int {
        if range.contains(0) {
            return self.output(at: 0)
        } else {
            return .init(nil)
        }
    }
    
    public func prefix(_ maxLength: Int) -> Publishers.Optional<Output, Failure> {
        precondition(maxLength > 0)
        return .init(self.result.map { $0 })
    }
    
    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return .init(self.result.map {
            if predicate($0) {
                return $0
            }
            return nil
        })
    }
    
    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return .init(self.result.tryMap {
            if try predicate($0) {
                return $0
            }
            return nil
        })
    }
    
    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Publishers.Once<Output, Error> {
        return self.mapError { $0 }
    }
    
    public func replaceError(with output: Output) -> Publishers.Once<Output, Never> {
        switch self.result {
        case .success(let output):
            return .init(output)
        case .failure:
            return .init(output)
        }
    }
    
    public func replaceEmpty(with output: Output) -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func retry(_ times: Int) -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func retry() -> Publishers.Once<Output, Failure> {
        return self
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Failure> {
        return .init(self.result.map {
            nextPartialResult(initialResult, $0)
        })
    }
    
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return .init(self.result.tryMap {
            try nextPartialResult(initialResult, $0)
        })
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

extension Publishers.Once where Failure == Never {
    
    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Once<Output, E> where E : Error {
        return self.mapError { _ -> E in
        }
    }
}

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
        public func receive<S>(subscriber: S)
        where S : Subscriber, S.Input == Output, S.Failure == Failure
        {
            let subscription = Inner(once: self.result, sub: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Once {
    
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
        let once: Result<Output, Failure>
        
        var sub: S?
        
        init(once: Result<Output, Failure>, sub: S) {
            self.once = once
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                switch self.once {
                case .success(let output):
                    _ = self.sub?.receive(output)
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
            return "Once"
        }
        
        var debugDescription: String {
            return "Once"
        }
    }
}
