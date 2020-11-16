#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    // swiftlint:disable:next syntactic_sugar
    typealias Optional<Wrapped> = Swift.Optional<Wrapped>.CX
}

extension Optional: CXWrapping {
    
    public struct CX: CXWrapper {
        
        public typealias Base = Wrapped?
        
        public let base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
    }
}

extension Optional.CX {
    
    public var publisher: Publisher {
        return .init(self.base)
    }
}

extension Optional.CX {
    
    /// A publisher that publishes an optional value to each subscriber exactly once, if the optional has a value.
    ///
    /// In contrast with `Just`, an `Optional` publisher may send no value before completion.
    public struct Publisher: CombineX.Publisher {

        public typealias Output = Wrapped

        public typealias Failure = Never

        /// The result to deliver to each subscriber.
        public let output: Wrapped?

        /// Creates a publisher to emit the optional value of a successful result, or fail with an error.
        ///
        /// - Parameter result: The result to deliver to each subscriber.
        public init(_ output: Output?) {
            self.output = output
        }

        public func receive<S: Subscriber>(subscriber: S) where Wrapped == S.Input, S.Failure == Failure {
            guard let output = output else {
                subscriber.receive(subscription: Subscriptions.empty)
                subscriber.receive(completion: .finished)
                return
            }
            Just(output).receive(subscriber: subscriber)
        }
    }
}

extension Optional.CX.Publisher: Equatable where Wrapped: Equatable {}

extension Optional.CX.Publisher where Wrapped: Equatable {
    
    public func contains(_ output: Output) -> Optional<Bool>.CX.Publisher {
        return .init(self.output.map { $0 == output })
    }
    
    public func removeDuplicates() -> Optional<Wrapped>.CX.Publisher {
        return self
    }
}

extension Optional.CX.Publisher where Wrapped: Comparable {
    
    public func min() -> Optional<Wrapped>.CX.Publisher {
        return self
    }
    
    public func max() -> Optional<Wrapped>.CX.Publisher {
        return self
    }
}

extension Optional.CX.Publisher {
    
    public func allSatisfy(_ predicate: (Output) -> Bool) -> Optional<Bool>.CX.Publisher {
        return .init(output.map(predicate))
    }
    
    public func collect() -> Optional<[Output]>.CX.Publisher {
        return .init(output.map { [$0] } ?? [])
    }
    
    public func compactMap<ElementOfResult>(_ transform: (Output) -> ElementOfResult?) -> Optional<ElementOfResult>.CX.Publisher {
        return .init(output.flatMap(transform))
    }
    
    public func min(by areInIncreasingOrder: (Output, Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return self
    }
    
    public func max(by areInIncreasingOrder: (Output, Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return self
    }
    
    public func contains(where predicate: (Output) -> Bool) -> Optional<Bool>.CX.Publisher {
        return .init(output.map(predicate))
    }
    
    public func count() -> Optional<Int>.CX.Publisher {
        return .init(output.map { _ in 1 })
    }
    
    public func dropFirst(_ count: Int = 1) -> Optional<Output>.CX.Publisher {
        precondition(count >= 0, "count must not be negative")
        return .init(count == 0 ? output : nil)
    }
    
    public func drop(while predicate: (Wrapped) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(output.filter { !predicate($0) })
    }
    
    public func first() -> Optional<Output>.CX.Publisher {
        return self
    }
    
    public func first(where predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(output.filter(predicate))
    }
    
    public func last() -> Optional<Output>.CX.Publisher {
        return self
    }
    
    public func last(where predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(output.filter(predicate))
    }
    
    public func filter(_ isIncluded: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(output.filter(isIncluded))
    }
    
    public func ignoreOutput() -> Empty<Output, Failure> {
        return .init()
    }
    
    public func map<ElementOfResult>(_ transform: (Output) -> ElementOfResult) -> Optional<ElementOfResult>.CX.Publisher {
        return .init(output.map(transform))
    }
    
    public func output(at index: Int) -> Optional<Output>.CX.Publisher {
        precondition(index >= 0, "index must not be negative")
        return .init(index == 0 ? output : nil)
    }
    
    public func output<RangeExpression: Swift.RangeExpression>(in range: RangeExpression) -> Optional<Output>.CX.Publisher where RangeExpression.Bound == Int {
        let range = range.relative(to: 0 ..< Int.max)
        precondition(range.lowerBound >= 0, "lowerBould must not be negative")
        return .init(range.contains(0) ? output : nil)
    }
    
    public func prefix(_ maxLength: Int) -> Optional<Output>.CX.Publisher {
        precondition(maxLength >= 0, "maxLength must not be negative")
        return .init(maxLength > 0 ? output : nil)
    }
    
    public func prefix(while predicate: (Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return .init(output.filter(predicate))
    }
    
    public func reduce<Accumulator>(_ initialResult: Accumulator, _ nextPartialResult: (Accumulator, Output) -> Accumulator) -> Optional<Accumulator>.CX.Publisher {
        return .init(output.map { nextPartialResult(initialResult, $0) })
    }
    
    public func scan<ElementOfResult>(_ initialResult: ElementOfResult, _ nextPartialResult: (ElementOfResult, Output) -> ElementOfResult) -> Optional<ElementOfResult>.CX.Publisher {
        return .init(output.map { nextPartialResult(initialResult, $0) })
    }
    
    public func removeDuplicates(by predicate: (Output, Output) -> Bool) -> Optional<Output>.CX.Publisher {
        return self
    }
    
    public func replaceError(with output: Output) -> Optional<Output>.CX.Publisher {
        return self
    }
    
    public func replaceEmpty(with output: Output) -> Just<Output> {
        return .init(self.output ?? output)
    }
    
    public func retry(_ times: Int) -> Optional<Output>.CX.Publisher {
        return self
    }
}
