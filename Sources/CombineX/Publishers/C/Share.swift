extension Publisher {
    
    /// Returns a publisher as a class instance.
    ///
    /// The downstream subscriber receieves elements and completion states unchanged from the
    /// upstream publisher. Use this operator when you want to use reference semantics, such as storing a
    /// publisher instance in a property.
    ///
    /// - Returns: A class instance that republishes its upstream publisher.
    public func share() -> Publishers.Share<Self> {
        return .init(upstream: self)
    }
}

extension Publishers {
    
    /// A publisher implemented as a class, which otherwise behaves like its upstream publisher.
    public final class Share<Upstream>: Publisher, Equatable where Upstream: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        public final let upstream: Upstream
        
        private lazy var pub = self.upstream
            .multicast(subject: PassthroughSubject<Output, Failure>())
            .autoconnect()
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public final func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.pub.receive(subscriber: subscriber)
        }
        
        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: Publishers.Share<Upstream>, rhs: Publishers.Share<Upstream>) -> Bool {
            return lhs === rhs
        }
    }
}
