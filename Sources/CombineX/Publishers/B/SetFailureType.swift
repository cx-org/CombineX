extension Publisher where Failure == Never {
    
    /// Changes the failure type declared by the upstream publisher.
    ///
    /// The publisher returned by this method cannot actually fail with the specified type and instead just
    /// finishes normally. Instead, you use this method when you need to match the error types of two
    /// mismatched publishers.
    ///
    /// - Parameter failureType: The `Failure` type presented by this publisher.
    /// - Returns: A publisher that appears to send the specified failure type.
    public func setFailureType<E: Error>(to failureType: E.Type) -> Publishers.SetFailureType<Self, E> {
        return .init(upstream: self)
    }
}

extension Publishers.SetFailureType: Equatable where Upstream: Equatable {}

extension Publishers {
    
    /// A publisher that appears to send a specified failure type.
    ///
    /// The publisher cannot actually fail with the specified type and instead just finishes normally. Use this
    /// publisher type when you need to match the error types for two mismatched publishers.
    public struct SetFailureType<Upstream: Publisher, Failure: Error>: Publisher where Upstream.Failure == Never {
        
        public typealias Output = Upstream.Output
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// Creates a publisher that appears to send a specified failure type.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Upstream.Output == S.Input {
            func dummy<T>(_: Never) -> T {}
            self.upstream
                .mapError(dummy)
                .receive(subscriber: subscriber)
        }
        
        public func setFailureType<E: Error>(to failure: E.Type) -> Publishers.SetFailureType<Upstream, E> {
            return Publishers.SetFailureType(upstream: self.upstream)
        }
    }
}
