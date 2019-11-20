extension Publisher where Output: Equatable {
    
    /// Publishes only elements that don’t match the previous element.
    ///
    /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
    public func removeDuplicates() -> Publishers.RemoveDuplicates<Self> {
        return .init(upstream: self, predicate: ==)
    }
}

extension Publisher {
    
    /// Publishes only elements that don’t match the previous element, as evaluated by a provided closure.
    /// 
    /// - Parameter predicate: A closure to evaluate whether two elements are equivalent, for
    /// purposes of filtering. Return `true` from this closure to indicate that the second element is a duplicate of the first.
    public func removeDuplicates(by predicate: @escaping (Output, Output) -> Bool) -> Publishers.RemoveDuplicates<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that publishes only elements that don’t match the previous element.
    public struct RemoveDuplicates<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A closure to evaluate whether two elements are equivalent, for purposes of filtering.
        public let predicate: (Upstream.Output, Upstream.Output) -> Bool
        
        /// Creates a publisher that publishes only elements that don’t match the previous element, as
        /// evaluated by a provided closure.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        /// - Parameter predicate: A closure to evaluate whether two elements are equivalent,
        /// for purposes of filtering. Return `true` from this closure to indicate that the second element
        /// is a duplicate of the first.
        public init(upstream: Upstream, predicate: @escaping (Publishers.RemoveDuplicates<Upstream>.Output, Publishers.RemoveDuplicates<Upstream>.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .tryRemoveDuplicates(by: self.predicate)
                .mapError {
                    $0 as! Failure
                }
                .receive(subscriber: subscriber)
        }
    }
}
