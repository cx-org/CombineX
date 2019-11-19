extension Publisher {
    
    /// Only publishes the last element of a stream that satisfies a predicate closure, after the stream finishes.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether to publish the element.
    /// - Returns: A publisher that only publishes the last element satisfying the given predicate.
    public func last(where predicate: @escaping (Output) -> Bool) -> Publishers.LastWhere<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that only publishes the last element of a stream that satisfies a predicate closure, once the stream finishes.
    public struct LastWhere<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that determines whether to publish an element.
        public let predicate: (Upstream.Output) -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Publishers.LastWhere<Upstream>.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .tryLast(where: self.predicate)
                .mapError {
                    $0 as! Failure
                }
                .receive(subscriber: subscriber)
        }
    }
}
