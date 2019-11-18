extension Publisher {
    
    /// Omits the specified number of elements before republishing subsequent elements.
    ///
    /// - Parameter count: The number of elements to omit.
    /// - Returns: A publisher that does not republish the first `count` elements.
    public func dropFirst(_ count: Int = 1) -> Publishers.Drop<Self> {
        return .init(upstream: self, count: count)
    }
}

extension Publishers.Drop : Equatable where Upstream : Equatable {
    
    /// Returns a Boolean value that indicates whether the two publishers are equivalent.
    ///
    /// - Parameters:
    ///   - lhs: A drop publisher to compare for equality..
    ///   - rhs: Another drop publisher to compare for equality..
    /// - Returns: `true` if the publishers have equal upstream and count properties, `false` otherwise.
    public static func == (lhs: Publishers.Drop<Upstream>, rhs: Publishers.Drop<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream && lhs.count == rhs.count
    }
}

extension Publishers {
    
    /// A publisher that omits a specified number of elements before republishing later elements.
    public struct Drop<Upstream> : Publisher where Upstream : Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The number of elements to drop.
        public let count: Int
        
        public init(upstream: Upstream, count: Int) {
            self.upstream = upstream
            self.count = count
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            return self.upstream
                .output(in: self.count...)
                .receive(subscriber: subscriber)
        }
    }
}
