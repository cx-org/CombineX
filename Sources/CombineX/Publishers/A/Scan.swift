extension Publisher {
    
    /// Transforms elements from the upstream publisher by providing the current element to a closure along with the last value returned by the closure.
    ///
    ///     let pub = (0...5)
    ///         .publisher
    ///         .scan(0, { return $0 + $1 })
    ///         .sink(receiveValue: { print ("\($0)", terminator: " ") })
    ///      // Prints "0 1 3 6 10 15 ".
    ///
    ///
    /// - Parameters:
    ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
    ///   - nextPartialResult: A closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
    /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
    public func scan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Self.Output) -> T) -> Publishers.Scan<Self, T> {
        return .init(upstream: self, initialResult: initialResult, nextPartialResult: nextPartialResult)
    }
    
}

extension Publishers {
    
    public struct Scan<Upstream, Output> : Publisher where Upstream : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let initialResult: Output
        
        public let nextPartialResult: (Output, Upstream.Output) -> Output
        
        public init(upstream: Upstream, initialResult: Output, nextPartialResult: @escaping (Output, Upstream.Output) -> Output) {
            self.upstream = upstream
            self.initialResult = initialResult
            self.nextPartialResult = nextPartialResult
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, Upstream.Failure == S.Failure {
            self.upstream
                .tryScan(self.initialResult, self.nextPartialResult)
                .mapError {
                    $0 as! Failure    
                }
                .receive(subscriber: subscriber)
        }
    }
    
}
