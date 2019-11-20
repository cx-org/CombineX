extension Publisher {
    
    /// Transforms all elements from the upstream publisher with a provided error-throwing closure.
    ///
    /// If the `transform` closure throws an error, the publisher fails with the thrown error.
    /// - Parameter transform: A closure that takes one element as its parameter and returns a new element.
    /// - Returns: A publisher that uses the provided closure to map elements from the upstream publisher to new elements that it then publishes.
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Self, T> {
        return .init(upstream: self, transform: transform)
    }
}

extension Publishers.TryMap {
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.TryMap<Upstream, T> {
        let newTransform: (Upstream.Output) throws -> T = {
            do {
                let output = try self.transform($0)
                return transform(output)
            } catch {
                throw error
            }
        }
        return self.upstream.tryMap(newTransform)
    }
    
    public func tryMap<T>(_ transform: @escaping (Output) throws -> T) -> Publishers.TryMap<Upstream, T> {
        let newTransform: (Upstream.Output) throws -> T = {
            do {
                let output = try self.transform($0)
                return try transform(output)
            } catch {
                throw error
            }
        }
        return self.upstream.tryMap(newTransform)
    }
}

extension Publishers {
    
    /// A publisher that transforms all elements from the upstream publisher with a provided error-throwing closure.
    public struct TryMap<Upstream: Publisher, Output>: Publisher {
        
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The error-throwing closure that transforms elements from the upstream publisher.
        public let transform: (Upstream.Output) throws -> Output
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) throws -> Output) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.TryMap<Upstream, Output>.Failure {
            self.upstream
                .tryCompactMap(self.transform)
                .receive(subscriber: subscriber)
        }
    }
}
