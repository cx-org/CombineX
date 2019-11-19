extension Publisher {
    
    /// Publishes a Boolean value upon receiving an element that satisfies the predicate closure.
    ///
    /// This operator consumes elements produced from the upstream publisher until the upstream publisher produces a matching element.
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether the element satisfies the closure’s comparison logic.
    /// - Returns: A publisher that emits the Boolean value `true` when the upstream  publisher emits a matching value.
    public func contains(where predicate: @escaping (Output) -> Bool) -> Publishers.ContainsWhere<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that emits a Boolean value upon receiving an element that satisfies the predicate closure.
    public struct ContainsWhere<Upstream: Publisher>: Publisher {
        
        public typealias Output = Bool
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that determines whether the publisher should consider an element as a match.
        public let predicate: (Upstream.Output) -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, S.Input == Publishers.ContainsWhere<Upstream>.Output {
            self.upstream
                .first(where: self.predicate)
                .map { _ in true }
                .receive(subscriber: subscriber)
        }
    }
}
