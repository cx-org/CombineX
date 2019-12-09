extension Publisher {
    
    /// Collects all received elements, and emits a single array of the collection when the upstream publisher finishes.
    ///
    /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
    /// This publisher requests an unlimited number of elements from the upstream publisher. It only sends the collected array to its downstream after a request whose demand is greater than 0 items.
    /// Note: This publisher uses an unbounded amount of memory to store the received values.
    ///
    /// - Returns: A publisher that collects all received items and returns them as an array upon completion.
    public func collect() -> Publishers.Collect<Self> {
        return .init(upstream: self)
    }
}

extension Publishers.Collect: Equatable where Upstream: Equatable {}

extension Publishers {
    
    /// A publisher that buffers items.
    public struct Collect<Upstream: Publisher>: Publisher {
        
        public typealias Output = [Upstream.Output]
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, S.Input == [Upstream.Output] {
            self.upstream
                .collect(.max)
                .receive(subscriber: subscriber)
        }
    }
}
