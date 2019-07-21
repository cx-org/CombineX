extension Publisher {
    
    /// Calls a closure with each received element and publishes any returned optional that has a value.
    ///
    /// - Parameter transform: A closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    public func compactMap<T>(_ transform: @escaping (Self.Output) -> T?) -> Publishers.CompactMap<Self, T> {
        return .init(upstream: self, transform: transform)
    }
}

extension Publishers.CompactMap {
    
    public func compactMap<T>(_ transform: @escaping (Output) -> T?) -> Publishers.CompactMap<Upstream, T> {
        return self.upstream.compactMap {
            if let output = self.transform($0) {
                return transform(output)
            }
            return nil
        }
    }
    
    public func map<T>(_ transform: @escaping (Output) -> T) -> Publishers.CompactMap<Upstream, T> {
        return self.upstream.compactMap {
            if let output = self.transform($0) {
                return transform(output)
            }
            return nil
        }
    }
}

extension Publishers {
    
    /// A publisher that republishes all non-`nil` results of calling a closure with each received element.
    public struct CompactMap<Upstream, Output> : Publisher where Upstream : Publisher {
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// A closure that receives values from the upstream publisher and returns optional values.
        public let transform: (Upstream.Output) -> Output?
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) -> Output?) {
            self.upstream = upstream
            self.transform = transform
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where Output == S.Input, S : Subscriber, Upstream.Failure == S.Failure {
            self.upstream
                .tryCompactMap(self.transform)
                .mapError {
                    $0 as! Failure
                }
                .receive(subscriber: subscriber)
        }
    }
}
