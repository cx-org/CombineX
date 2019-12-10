extension Publisher {
    
    /// Publishes the first element of a stream, then finishes.
    ///
    /// If this publisher doesn’t receive any elements, it finishes without publishing.
    /// - Returns: A publisher that only publishes the first element of a stream.
    public func first() -> Publishers.First<Self> {
        return .init(upstream: self)
    }
}

extension Publishers.First: Equatable where Upstream: Equatable {}

extension Publishers {
    
    /// A publisher that publishes the first element of a stream, then finishes.
    public struct First<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            return self.upstream
                .output(at: 0)
                .receive(subscriber: subscriber)
        }
    }
}
