extension Publisher {
    
    /// Republishes elements while a predicate closure indicates publishing should continue.
    ///
    /// The publisher finishes when the closure returns `false`.
    ///
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
    /// - Returns: A publisher that passes through elements until the predicate indicates publishing should finish.
    public func prefix(while predicate: @escaping (Output) -> Bool) -> Publishers.PrefixWhile<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that republishes elements while a predicate closure indicates publishing should continue.
    public struct PrefixWhile<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that determines whether whether publishing should continue.
        public let predicate: (Upstream.Output) -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Publishers.PrefixWhile<Upstream>.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .tryPrefix(while: self.predicate)
                .mapError {
                    $0 as! Failure    
                }
                .receive(subscriber: subscriber)
        }
    }
}
