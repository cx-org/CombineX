import Foundation

extension Publishers.Just {
    
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Publishers.Just<Bool> {
        return .init(predicate(self.output))
    }
    
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return .init(Result {
            try predicate(self.output)
        })
    }
    
    public func collect() -> Publishers.Just<[Output]> {
        return .init([self.output])
    }
    
    public func compactMap<T>(_ transform: (Output) -> T?) -> Publishers.Optional<T, Publishers.Just<Output>.Failure> {
        return .init(transform(self.output))
    }
    
    public func tryCompactMap<T>(_ transform: (Output) throws -> T?) -> Publishers.Optional<T, Error> {
        return .init(Result {
            try transform(self.output)
        })
    }
    
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }
    
    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Never> {
        return .init(self.output)
    }

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Publishers.Just<Output> {
        return self
    }
    
    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Publishers.Optional<Output, Never> {
        return .init(self.output)
    }
    
    public func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> {
        return .init(sequence: elements + [self.output])
    }
    
    public func prepend<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Sequence {
        return .init(sequence: elements + [self.output])
    }
    
    public func append(_ elements: Output...) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> {
        return .init(sequence: [self.output] + elements)
    }
    
    public func append<S>(_ elements: S) -> Publishers.Sequence<[Output], Publishers.Just<Output>.Failure> where Output == S.Element, S : Sequence {
        return .init(sequence: [self.output] + elements)
    }
    
    public func contains(where predicate: (Output) -> Bool) -> Publishers.Just<Bool> {
        return self.allSatisfy(predicate)
    }
    
    public func tryContains(where predicate: (Output) throws -> Bool) -> Publishers.Once<Bool, Error> {
        return self.tryAllSatisfy(predicate)
    }
    
    public func count() -> Publishers.Just<Int> {
        return .init(1)
    }
    
    public func dropFirst(_ count: Int = 1) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        precondition(count >= 0)
        
        if count == 0 {
            return self.compactMap { $0 }
        } else {
            return .init(nil)
        }
    }
    
    public func drop(while predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
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
    
    public func first() -> Publishers.Just<Output> {
        return self
    }
    
    public func first(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
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
    
    public func last() -> Publishers.Just<Output> {
        return self.first()
    }
    
    public func last(where predicate: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.first(where: predicate)
    }
    
    public func tryLast(where predicate: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFirst(where: predicate)
    }
    
    public func filter(_ isIncluded: (Output) -> Bool) -> Publishers.Optional<Output, Publishers.Just<Output>.Failure> {
        return self.first(where: isIncluded)
    }
    
    public func tryFilter(_ isIncluded: (Output) throws -> Bool) -> Publishers.Optional<Output, Error> {
        return self.tryFirst(where: isIncluded)
    }
    
    public func ignoreOutput() -> Publishers.Empty<Output, Publishers.Just<Output>.Failure> {
        return .init()
    }
    
    public func map<T>(_ transform: (Output) -> T) -> Publishers.Just<T> {
        return .init(transform(self.output))
    }
    
    public func tryMap<T>(_ transform: (Output) throws -> T) -> Publishers.Once<T, Error> {
        return .init(Result {
            try transform(self.output)
        })
    }
    
    public func mapError<E>(_ transform: (Publishers.Just<Output>.Failure) -> E) -> Publishers.Once<Output, E> where E : Error {
        return .init(self.output)
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Publishers.Once<T, Publishers.Just<Output>.Failure> {
        return .init(nextPartialResult(initialResult, self.output))
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Publishers.Once<T, Error> {
        return .init(Result {
            try nextPartialResult(initialResult, self.output)
        })
    }
    
    public func setFailureType<E>(to failureType: E.Type) -> Publishers.Once<Output, E> where E : Error {
        return .init(self.output)
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
            Publishers.Once<Output, Never>(self.output).receive(subscriber: subscriber)
        }
    }
}
