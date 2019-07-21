extension Publisher {
    
    /// Transforms all elements from the upstream publisher with a provided closure.
    ///
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func map<T>(_ transform: @escaping (Self.Output) -> T) -> Publishers.Map<Self, T> {
        return .init(upstream: self, transform: transform)
    }
}

extension Publisher {
    
    /// Replaces nil elements in the stream with the proviced element.
    ///
    /// - Parameter output: The element to use when replacing `nil`.
    /// - Returns: A publisher that replaces `nil` elements from the upstream publisher with the provided element.
    public func replaceNil<T>(with output: T) -> Publishers.Map<Self, T> where Self.Output == T? {
        return self.map { $0 ?? output }
    }
}

extension Publishers.Map {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.Map<Upstream, T> {
        let newTransform: (Upstream.Output) -> T = {
            transform(self.transform($0))
        }
        return self.upstream.map(newTransform)
    }
    
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T> {
        let newTransform: (Upstream.Output) throws -> T = {
            try transform(self.transform($0))
        }
        return self.upstream.tryMap(newTransform)
    }
}

extension Publishers {
    
    /// A publisher that transforms all elements from the upstream publisher with a provided closure.
    public struct Map<Upstream, Output> : Publisher where Upstream : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that transforms elements from the upstream publisher.
        public let transform: (Upstream.Output) -> Output
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output) {
            self.upstream = upstream
            self.transform = transform
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, Upstream.Failure == S.Failure {
            self.upstream
                .compactMap(self.transform)
                .receive(subscriber: subscriber)
        }
    }
}
