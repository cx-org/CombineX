extension Publisher {
    
    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func min(by areInIncreasingOrder: @escaping (Output, Output) -> Bool) -> Publishers.Comparison<Self> {
        return .init(upstream: self) {
            !areInIncreasingOrder($0, $1)
        }
    }
    
    /// Publishes the maximum value received from the upstream publisher, using the provided ordering closure.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Parameter areInIncreasingOrder: A closure that receives two elements and returns `true` if they are in increasing order.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func max(by areInIncreasingOrder: @escaping (Output, Output) -> Bool) -> Publishers.Comparison<Self> {
        return .init(upstream: self, areInIncreasingOrder: areInIncreasingOrder)
    }
}

extension Publisher where Output: Comparable {
    
    /// Publishes the minimum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the minimum value received from the upstream publisher, after the upstream publisher finishes.
    public func min() -> Publishers.Comparison<Self> {
        return self.min(by: <)
    }
    
    /// Publishes the maximum value received from the upstream publisher, after it finishes.
    ///
    /// After this publisher receives a request for more than 0 items, it requests unlimited items from its upstream publisher.
    /// - Returns: A publisher that publishes the maximum value received from the upstream publisher, after the upstream publisher finishes.
    public func max() -> Publishers.Comparison<Self> {
        return self.max(by: <)
    }
}

extension Publishers {
    
    /// A publisher that republishes items from another publisher only if each new item is in increasing order from the previously-published item.
    public struct Comparison<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream
        
        /// A closure that receives two elements and returns `true` if they are in increasing order.
        public let areInIncreasingOrder: (Upstream.Output, Upstream.Output) -> Bool
        
        public init(upstream: Upstream, areInIncreasingOrder: @escaping (Upstream.Output, Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.areInIncreasingOrder = areInIncreasingOrder
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .tryMax(by: self.areInIncreasingOrder)
                .mapError {
                    $0 as! Failure
                }
                .receive(subscriber: subscriber)
        }
    }
}
