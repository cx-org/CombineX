extension Publisher {
    
    /// Publishes a single Boolean value that indicates whether all received elements pass a given predicate.
    ///
    /// When this publisher receives an element, it runs the predicate against the element. If the predicate
    /// returns `false`, the publisher produces a `false` value and finishes. If the upstream publisher
    /// finishes normally, this publisher produces a `true` value and finishes.
    ///
    /// As a `reduce`-style operator, this publisher produces at most one value.
    ///
    /// Backpressure note: Upon receiving any request greater than zero, this publisher requests unlimited
    /// elements from the upstream publisher.
    ///
    /// - Parameter predicate: A closure that evaluates each received element. Return `true` to
    /// continue, or `false` to cancel the upstream and complete.
    /// - Returns: A publisher that publishes a Boolean value that indicates whether all received
    /// elements pass a given predicate.
    public func allSatisfy(_ predicate: @escaping (Output) -> Bool) -> Publishers.AllSatisfy<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that publishes a single Boolean value that indicates whether all received elements pass a given predicate.
    public struct AllSatisfy<Upstream: Publisher>: Publisher {
        
        public typealias Output = Bool
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A closure that evaluates each received element.
        ///
        ///  Return `true` to continue, or `false` to cancel the upstream and finish.
        public let predicate: (Upstream.Output) -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, S.Input == Publishers.AllSatisfy<Upstream>.Output {
            self.upstream
                .tryAllSatisfy(self.predicate)
                .mapError {
                    $0 as! Failure
                }
                .receive(subscriber: subscriber)
        }
    }
}
