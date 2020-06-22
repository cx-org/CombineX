#if !COCOAPODS
import CXUtility
#endif

/// A publisher that emits an output to each subscriber just once, and then finishes.
///
/// You can use a `Just` publisher to start a chain of publishers. A `Just` publisher is also useful when replacing a value with `Catch`.
///
/// In contrast with `Publishers.Once`, a `Just` publisher cannot fail with an error.
public struct Just<Output>: Publisher {
    
    public typealias Failure = Never
    
    /// The one element that the publisher emits.
    public let output: Output
    
    /// Initializes a publisher that emits the specified output just once.
    ///
    /// - Parameter output: The one element that the publisher emits.
    public init(_ output: Output) {
        self.output = output
    }
    
    public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Just<Output>.Failure {
        let s = Inner(pub: self, sub: subscriber)
        subscriber.receive(subscription: s)
    }
}

extension Just {
    
    private final class Inner<S>: Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        
        typealias Pub = Just<Output>
        typealias Sub = S
        
        let lock = Lock()
        let output: Output
        
        var sub: Sub?
        var state = DemandState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.output = pub.output
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)

            self.lock.lock()
            guard self.state.isWaiting else {
                self.lock.unlock()
                return
            }
            
            self.state = .completed
            
            let sub = self.sub!
            self.sub = nil
            
            self.lock.unlock()
            
            _ = sub.receive(output)
            sub.receive(completion: .finished)
        }
        
        func cancel() {
            self.lock.withLock {
                self.state = .completed
                self.sub = nil
            }
        }
        
        var description: String {
            return "Just"
        }
        
        var debugDescription: String {
            return "Just"
        }
    }
}

extension Just: Equatable where Output: Equatable {}

extension Just where Output: Equatable {
    
    public func contains(_ output: Output) -> Just<Bool> {
        return .init(self.output == output)
    }
    
    public func removeDuplicates() -> Just<Output> {
        return self
    }
}

extension Just where Output: Comparable {
    
    public func min() -> Just<Output> {
        return self
    }
    
    public func max() -> Just<Output> {
        return self
    }
}

extension Just {
    
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Just<Bool> {
        return .init(predicate(self.output))
    }
    
    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Result<Bool, Error>.CX.Publisher {
        return .init(Result {
            try predicate(self.output)
        })
    }
    
    public func collect() -> Just<[Output]> {
        return .init([self.output])
    }
    
    public func compactMap<T>(_ transform: (Output) -> T?) -> Optional<T>.CX.Publisher {
        return .init(transform(self.output))
    }
    
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Just<Output> {
        return self
    }

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Just<Output> {
        return self
    }
    
    public func prepend(_ elements: Output...) -> Publishers.Sequence<[Output], Failure> {
        return .init(sequence: elements + [self.output])
    }
    
    public func prepend<S: Sequence>(_ elements: S) -> Publishers.Sequence<[Output], Failure> where Output == S.Element {
        return .init(sequence: elements + [self.output])
    }
    
    public func append(_ elements: Output...) -> Publishers.Sequence<[Output], Failure> {
        return .init(sequence: [self.output] + elements)
    }
    
    public func append<S: Sequence>(_ elements: S) -> Publishers.Sequence<[Output], Failure> where Output == S.Element {
        return .init(sequence: [self.output] + elements)
    }
    
    public func contains(where predicate: (Output) -> Bool) -> Just<Bool> {
        return self.allSatisfy(predicate)
    }
    
    public func tryContains(where predicate: (Output) throws -> Bool) -> Result<Bool, Error>.CX.Publisher {
        return self.tryAllSatisfy(predicate)
    }
    
    public func count() -> Just<Int> {
        return .init(1)
    }
    
    public func dropFirst(_ count: Int = 1) -> Optional<Output>.CX.Publisher {
        precondition(count >= 0)
        return count == 0 ? self.compactMap { $0 } : .init(nil)
    }
    
    public func drop(while predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return self.compactMap {
            predicate($0) ? nil : $0
        }
    }
    
    public func first() -> Just<Output> {
        return self
    }
    
    public func first(where predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return self.compactMap {
            predicate($0) ? $0 : nil
        }
    }
    
    public func last() -> Just<Output> {
        return self.first()
    }
    
    public func last(where predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return self.first(where: predicate)
    }
    
    public func filter(_ isIncluded: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return self.first(where: isIncluded)
    }
    
    public func ignoreOutput() -> Empty<Output, Just<Output>.Failure> {
        return .init()
    }
    
    public func map<T>(_ transform: (Output) -> T) -> Just<T> {
        return .init(transform(self.output))
    }
    
    public func tryMap<T>(_ transform: (Output) throws -> T) -> Result<T, Error>.CX.Publisher {
        return .init(Result {
            try transform(self.output)
        })
    }
    
    public func mapError<E: Error>(_ transform: (Just<Output>.Failure) -> E) -> Result<Output, E>.CX.Publisher {
        return .init(self.output)
    }
    
    public func output(at index: Int) -> Optional<Output>.CX.Publisher {
        return index == 0 ? .init(self.output) : .init(nil)
    }
    
    public func output<R: RangeExpression>(in range: R) -> Optional<Output>.CX.Publisher where R.Bound == Int {
        return range.contains(0) ? .init(self.output) : .init(nil)
    }
    
    public func prefix(_ maxLength: Int) -> Optional<Output>.CX.Publisher {
        precondition(maxLength > 0)
        return .init(self.output)
    }
    
    public func prefix(while predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return predicate(self.output) ? .init(self.output) : .init(nil)
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Failure>.CX.Publisher {
        return .init(nextPartialResult(initialResult, self.output))
    }
    
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.CX.Publisher {
        return .init(Result {
            try nextPartialResult(initialResult, self.output)
        })
    }
    
    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Just<Output> {
        return self
    }
    
    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Result<Output, Error>.CX.Publisher {
        return .init(self.output)
    }
    
    public func replaceError(with output: Output) -> Just<Output> {
        return self
    }
    
    public func replaceEmpty(with output: Output) -> Just<Output> {
        return self
    }
    
    public func retry(_ times: Int) -> Just<Output> {
        return self
    }
    
    public func scan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) -> T) -> Result<T, Just<Output>.Failure>.CX.Publisher {
        return .init(nextPartialResult(initialResult, self.output))
    }
    
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: (T, Output) throws -> T) -> Result<T, Error>.CX.Publisher {
        return .init(Result {
            try nextPartialResult(initialResult, self.output)
        })
    }
    
    public func setFailureType<E: Error>(to failureType: E.Type) -> Result<Output, E>.CX.Publisher {
        return .init(self.output)
    }
}
