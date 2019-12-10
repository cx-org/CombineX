extension Publishers.Contains: Equatable where Upstream: Equatable {}

extension Publisher where Output: Equatable {
    
    /// Publishes a Boolean value upon receiving an element equal to the argument.
    ///
    /// The contains publisher consumes all received elements until the upstream publisher produces a
    /// matching element. At that point, it emits `true` and finishes normally. If the upstream finishes
    /// normally without producing a matching element, this publisher emits `false`, then finishes.
    /// 
    /// - Parameter output: An element to match against.
    /// - Returns: A publisher that emits the Boolean value `true` when the upstream publisher emits a matching value.
    public func contains(_ output: Output) -> Publishers.Contains<Self> {
        return .init(upstream: self, output: output)
    }
}

extension Publishers {
    
    /// A publisher that emits a Boolean value when a specified element is received from its upstream publisher.
    public struct Contains<Upstream>: Publisher where Upstream: Publisher, Upstream.Output: Equatable {
        
        public typealias Output = Bool
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The element to scan for in the upstream publisher.
        public let output: Upstream.Output
        
        public init(upstream: Upstream, output: Upstream.Output) {
            self.upstream = upstream
            self.output = output
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, S.Input == Publishers.Contains<Upstream>.Output {
            self.upstream
                .contains {
                    $0 == self.output
                }
                .receive(subscriber: subscriber)
        }
    }
}
