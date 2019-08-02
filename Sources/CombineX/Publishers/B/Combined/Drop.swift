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
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The number of elements to drop.
        public let count: Int
        
        public init(upstream: Upstream, count: Int) {
            self.upstream = upstream
            self.count = count
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            return self.upstream
                .output(in: self.count...)
                .receive(subscriber: subscriber)
        }
    }
}
