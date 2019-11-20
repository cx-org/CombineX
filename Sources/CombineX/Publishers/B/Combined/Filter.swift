extension Publisher {
    
    public func filter(_ isIncluded: @escaping (Output) -> Bool) -> Publishers.Filter<Self> {
        return .init(upstream: self, isIncluded: isIncluded)
    }
}

extension Publishers.Filter {
    
    public func tryFilter(_ isIncluded: @escaping (Publishers.Filter<Upstream>.Output) throws -> Bool) -> Publishers.TryFilter<Upstream> {
        let newIsIncluded: (Upstream.Output) throws -> Bool = {
            let lhs = self.isIncluded($0)
            let rhs = try isIncluded($0)
            return lhs && rhs
        }
        return self.upstream.tryFilter(newIsIncluded)
    }
}

extension Publishers {
    
    /// A publisher that republishes all elements that match a provided closure.
    public struct Filter<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A closure that indicates whether to republish an element.
        public let isIncluded: (Upstream.Output) -> Bool
        
        public init(upstream: Upstream, isIncluded: @escaping (Upstream.Output) -> Bool) {
            self.upstream = upstream
            self.isIncluded = isIncluded
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .compactMap {
                    self.isIncluded($0) ? $0 : nil
                }
                .receive(subscriber: subscriber)
        }
    }
}
