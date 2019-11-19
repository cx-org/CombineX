extension Publisher {
    
    /// Publishes the minimum value received from the upstream publisher, using the provided
    /// error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its
    /// upstream publisher.
    ///
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and
    /// returns `true` if they are in increasing order. If this closure throws, the publisher terminates with
    /// a `Failure`.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher,
    /// after the upstream publisher finishes.
    public func tryMin(by areInIncreasingOrder: @escaping (Output, Output) throws -> Bool) -> Publishers.TryComparison<Self> {
        return .init(upstream: self) {
            try !areInIncreasingOrder($0, $1)
        }
    }
    
    /// Publishes the maximum value received from the upstream publisher, using the provided
    /// error-throwing closure to order the items.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its
    /// upstream publisher.
    ///
    /// - Parameter areInIncreasingOrder: A throwing closure that receives two elements and
    /// returns `true` if they are in increasing order. If this closure throws, the publisher terminates with
    /// a `Failure`.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher,
    /// after the upstream publisher finishes.
    public func tryMax(by areInIncreasingOrder: @escaping (Output, Output) throws -> Bool) -> Publishers.TryComparison<Self> {
        return .init(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
    }
}

extension Publishers {
    
    // FIXME: The doc from Apple seems to be wrong, should be: A publisher that
    // only publishes the maximum value received from the upstream publisher,
    // after the upstream publisher finishes.
    /// A publisher that republishes items from another publisher only if each new item is in increasing order
    /// from the previously-published item, and fails if the ordering logic throws an error.
    public struct TryComparison<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Error
        
        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream
        
        /// A closure that receives two elements and returns `true` if they are in increasing order.
        public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) throws -> Bool
        
        public init(upstream: Upstream, areInIncreasingOrder: @escaping (Upstream.Output, Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.areInIncreasingOrder = areInIncreasingOrder
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, S.Failure == Publishers.TryComparison<Upstream>.Failure {
            
            self.upstream
                .tryReduce(nil as Output?) {
                    if let output = $0 {
                        return try self.areInIncreasingOrder(output, $1) ? $1 : output
                    } else {
                        return $1
                    }
                }
                .compactMap { $0 }
                .receive(subscriber: subscriber)
        }
    }
}
