extension Publisher {
    
    /// Only publishes the last element of a stream, after the stream finishes.
    /// - Returns: A publisher that only publishes the last element of a stream.
    public func last() -> Publishers.Last<Self> {
        return .init(upstream: self)
    }
}

extension Publishers.Last: Equatable where Upstream: Equatable {}

extension Publishers {
    
    /// A publisher that only publishes the last element of a stream, after the stream finishes.
    public struct Last<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .last { _ in true }
                .receive(subscriber: subscriber)
        }
    }
}
