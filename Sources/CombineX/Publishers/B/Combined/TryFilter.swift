extension Publisher {
    
    /// Republishes all elements that match a provided error-throwing closure.
    ///
    /// If the `isIncluded` closure throws an error, the publisher fails with that error.
    ///
    /// - Parameter isIncluded:  A closure that takes one element and returns a Boolean value indicating whether to republish the element.
    /// - Returns:  A publisher that republishes all elements that satisfy the closure.
    public func tryFilter(_ isIncluded: @escaping (Output) throws -> Bool) -> Publishers.TryFilter<Self> {
        return .init(upstream: self, isIncluded: isIncluded)
    }
}

extension Publishers.TryFilter {
    
    public func filter(_ isIncluded: @escaping (Publishers.TryFilter<Upstream>.Output) -> Bool) -> Publishers.TryFilter<Upstream> {
        return self.upstream
            .tryFilter {
                let a = try self.isIncluded($0)
                let b = isIncluded($0)
                return a && b
            }
    }
    
    public func tryFilter(_ isIncluded: @escaping (Publishers.TryFilter<Upstream>.Output) throws -> Bool) -> Publishers.TryFilter<Upstream> {
        return self.upstream
            .tryFilter {
                let a = try self.isIncluded($0)
                let b = try isIncluded($0)
                return a && b
            }
    }
}

extension Publishers {
    
    /// A publisher that republishes all elements that match a provided error-throwing closure.
    public struct TryFilter<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A error-throwing closure that indicates whether to republish an element.
        public let isIncluded: (Upstream.Output) throws -> Bool
        
        public init(upstream: Upstream, isIncluded: @escaping (Upstream.Output) throws -> Bool) {
            self.upstream = upstream
            self.isIncluded = isIncluded
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, S.Failure == Publishers.TryFilter<Upstream>.Failure {
            self.upstream
                .tryCompactMap {
                    try self.isIncluded($0) ? $0 : nil    
                }
                .receive(subscriber: subscriber)
        }
    }
}
