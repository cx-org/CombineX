#if !COCOAPODS
import CXNamespace
import CXUtility
#endif

extension CXWrappers {
    
    typealias Result<Success, Failure> = Swift.Result<Success, Failure>.CX where Failure: Error
}

extension Result: CXWrapping {
    
    public struct CX: CXWrapper {
        
        public typealias Base = Result<Success, Failure>
        
        public let base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
    }
}

extension Result.CX {
    
    public var publisher: Publisher {
        return .init(self.base)
    }
}

extension Result.CX {

    /// A publisher that publishes an output to each subscriber exactly once then finishes, or fails immediately without producing any elements.
    ///
    /// If `result` is `.success`, then `Once` waits until it receives a request for at least 1 value before sending the output. If `result` is `.failure`, then `Once` sends the failure immediately upon subscription.
    ///
    /// In contrast with `Just`, a `Once` publisher can terminate with an error instead of sending a value.
    /// In contrast with `Optional`, a `Once` publisher always sends one value (unless it terminates with an error).
    public struct Publisher: CombineX.Publisher {

        public typealias Output = Success

        /// The result to deliver to each subscriber.
        public let result: Result<Success, Failure>

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

        public func receive<S: Subscriber>(subscriber: S) where Success == S.Input, Failure == S.Failure {
            switch result {
            case .failure(let e):
                subscriber.receive(subscription: Subscriptions.empty)
                subscriber.receive(completion: .failure(e))
            case .success(let output):
                let s = Inner(output: output, sub: subscriber)
                subscriber.receive(subscription: s)
            }
        }
    }
}

extension Result.CX.Publisher {
    
    private final class Inner<S>: Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        
        typealias Sub = S
        
        let lock = Lock()
        let output: Output
        
        var state = DemandState.waiting
        var sub: Sub?
        
        init(output: Output, sub: Sub) {
            self.output = output
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
            return "Result.Publisher"
        }
        
        var debugDescription: String {
            return "Result.Publisher"
        }
    }
}

extension Result.CX.Publisher: Equatable where Success: Equatable, Failure: Equatable {}

extension Result.CX.Publisher where Output: Equatable {

    public func contains(_ output: Output) -> Result<Bool, Failure>.CX.Publisher {
        return .init(result.map { $0 == output })
    }

    public func removeDuplicates() -> Result<Output, Failure>.CX.Publisher {
        return self
    }
}

extension Result.CX.Publisher where Output: Comparable {

    public func min() -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func max() -> Result<Output, Failure>.CX.Publisher {
        return self
    }
}

extension Result.CX.Publisher {

    public func allSatisfy(_ predicate: (Output) -> Bool) -> Result<Bool, Failure>.CX.Publisher {
        return .init(result.map(predicate))
    }

    public func tryAllSatisfy(_ predicate: (Output) throws -> Bool) -> Result<Bool, Error>.CX.Publisher {
        return .init(result.tryMap(predicate))
    }

    public func contains(where predicate: (Output) -> Bool) -> Result<Bool, Failure>.CX.Publisher {
        return .init(result.map(predicate))
    }

    public func tryContains(where predicate: (Output) throws -> Bool) -> Result<Bool, Error>.CX.Publisher {
        return .init(result.tryMap(predicate))
    }

    public func collect() -> Result<[Output], Failure>.CX.Publisher {
        return .init(result.map { [$0] })
    }

    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func tryMin(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Result<Output, Error>.CX.Publisher {
        return .init(result.tryMap { _ = try areInIncreasingOrder($0, $0); return $0 })
    }

    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func tryMax(by areInIncreasingOrder: (Output, Output) throws -> Bool) -> Result<Output, Error>.CX.Publisher {
        return .init(result.tryMap { _ = try areInIncreasingOrder($0, $0); return $0 })
    }

    public func count() -> Result<Int, Failure>.CX.Publisher {
        return .init(result.map { _ in 1 })
    }

    public func first() -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func last() -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func ignoreOutput() -> Empty<Output, Failure> {
        return .init()
    }

    public func map<ElementOfResult>(_ transform: (Output) -> ElementOfResult) -> Result<ElementOfResult, Failure>.CX.Publisher {
        return .init(result.map(transform))
    }

    public func tryMap<ElementOfResult>(_ transform: (Output) throws -> ElementOfResult) -> Result<ElementOfResult, Error>.CX.Publisher {
        return .init(result.tryMap(transform))
    }

    public func mapError<TransformedFailure: Error>(_ transform: (Failure) -> TransformedFailure) -> Result<Output, TransformedFailure>.CX.Publisher {
        return .init(result.mapError(transform))
    }

    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func tryRemoveDuplicates(by predicate: (Output, Output) throws -> Bool) -> Result<Output, Error>.CX.Publisher {
        return .init(result.erasedError)
    }

    public func replaceError(with output: Output) -> Result<Output, Never>.CX.Publisher {
        return .init(result.replaceError(with: output))
    }

    public func replaceEmpty(with output: Output) -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func retry(_ times: Int) -> Result<Output, Failure>.CX.Publisher {
        return self
    }

    public func reduce<Accumulator>(_ initialResult: Accumulator, _ nextPartialResult: (Accumulator, Output) -> Accumulator) -> Result<Accumulator, Failure>.CX.Publisher {
        return .init(result.map { nextPartialResult(initialResult, $0) })
    }

    public func tryReduce<Accumulator>(_ initialResult: Accumulator, _ nextPartialResult: (Accumulator, Output) throws -> Accumulator) -> Result<Accumulator, Error>.CX.Publisher {
        return .init(result.tryMap { try nextPartialResult(initialResult, $0) })
    }

    public func scan<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: (ElementOfResult, Output) -> ElementOfResult) -> Result<ElementOfResult, Failure>.CX.Publisher {
        return .init(result.map { nextPartialResult(initialResult, $0) })
    }

    public func tryScan<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: (ElementOfResult, Output) throws -> ElementOfResult) -> Result<ElementOfResult, Error>.CX.Publisher {
        return .init(result.tryMap { try nextPartialResult(initialResult, $0) })
    }
}

extension Result.CX.Publisher where Failure == Never {

    public func setFailureType<Failure: Error>(to failureType: Failure.Type) -> Result<Output, Failure>.CX.Publisher {
        return .init(.success(result.success))
    }
}
