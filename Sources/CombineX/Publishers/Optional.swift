extension Publishers.Optional {
    
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure> {
        return .init(self.result.map {
            if let success = $0 {
                return predicate(success)
            }
            return false
        })
    }
    
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error> {
        return .init(self.result.tryMap {
            try $0.map { try predicate($0) }
        })
    }
    
    public func collect() -> Publishers.Optional<[Output], Failure> {
        return .init(self.result.map {
            $0.map { [$0] }
        })
    }
    
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Failure> {
        return .init(self.result.map {
            $0.flatMap(transform)
        })
    }
    
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        return .init(self.result.tryMap {
            try $0.flatMap(transform)
        })
    }
    
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func contains(where predicate: (Output) -> Bool) -> Publishers.Optional<Bool, Failure> {
        return self.allSatisfy(predicate)
    }
    
    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Bool, Error> {
        return self.tryAllSatisfy(predicate)
    }
    
    public func count() -> Publishers.Optional<Int, Failure> {
        return .init(self.result.map { _ in 1 })
    }
    
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Failure> {
        precondition(count >= 0)
        
        if count == 0 {
            return self
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
    
    public func first() -> Publishers.Optional<Output, Failure> {
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
    
    public func last() -> Publishers.Optional<Output, Failure> {
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
    
    public func map<T>(_ transform: (Output) -> T) -> Publishers.Optional<T, Failure> {
        return .init(self.result.map {
            $0.map(transform)
        })
    }
    
    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Optional<T, Error> {
        return .init(self.result.tryMap {
            try $0.map(transform)
        })
    }
    
    public func mapError<E>(_ transform: (Failure) -> E) -> Publishers.Optional<Output, E> where E : Error {
        return .init(self.result.mapError(transform))
    }

    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        return .init(self.result.map {
            $0.map {
                nextPartialResult(initialResult, $0)
            }
        })
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error> {
        return .init(self.result.tryMap {
            try $0.map {
                try nextPartialResult(initialResult, $0)
            }
        })
    }
    
    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) ->  Publishers.Optional<Output, Error> {
        return self.mapError { $0 }
    }
    
    public func output(at index: Int) -> Publishers.Optional<Output, Failure> {
        if index == 0 {
            return self
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
        return self
    }
    
    public func prefix(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Failure> {
        return .init(self.result.map({
            if let output = $0, predicate(output) {
                return output
            }
            return nil
        }))
    }
    
    public func tryPrefix(while predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return .init(self.result.tryMap {
            if let output = $0, try predicate(output) {
                return output
            }
            return nil
        })
    }
    
    public func replaceError(with output: Output) -> Publishers.Optional<Output, Never> {
        switch self.result {
        case .success(let output):
            return .init(output)
        case .failure:
            return .init(output)
        }
    }
    
    public func replaceEmpty(with output: Output) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func retry(_ times: Int) -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func retry() -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Optional<T, Failure> {
        return .init(self.result.map {
            guard let output = $0 else {
                return nil
            }
            return nextPartialResult(initialResult, output)
        })
    }
    
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Optional<T, Error> {
        return .init(self.result.tryMap {
            guard let output = $0 else {
                return nil
            }
            return try nextPartialResult(initialResult, output)
        })
    }
}

extension Publishers.Optional where Failure == Never {
    
    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Optional<Output, E> where E : Error {
        return self.mapError {
            $0 as! E
        }
    }
}

extension Publishers.Optional : Equatable where Output : Equatable, Failure : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Optional<Output, Failure>, rhs: Publishers.Optional<Output, Failure>) -> Bool {
        return lhs.result == rhs.result
    }
}

extension Publishers.Optional where Output : Equatable {
    
    public func contains(_ output: Output) -> Publishers.Optional<Bool, Failure> {
        return .init(self.result.map {
            $0 == output
        })
    }
    
    public func removeDuplicates() -> Publishers.Optional<Output, Failure> {
        return self
    }
}

extension Publishers.Optional where Output : Comparable {
    
    public func min() -> Publishers.Optional<Output, Failure> {
        return self
    }
    
    public func max() -> Publishers.Optional<Output, Failure> {
        return self
    }
}

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
