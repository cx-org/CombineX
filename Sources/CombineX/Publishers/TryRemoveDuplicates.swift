extension Publisher {
    
    public func tryRemoveDuplicates(by predicate: @escaping (Self.Output, Self.Output) throws -> Bool) -> Publishers.TryRemoveDuplicates<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    public struct TryRemoveDuplicates<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Error
        
        public let upstream: Upstream
        
        public let predicate: (Upstream.Output, Upstream.Output) throws -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Publishers.TryRemoveDuplicates<Upstream>.Output, Publishers.TryRemoveDuplicates<Upstream>.Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Output == S.Input, S.Failure == Publishers.TryRemoveDuplicates<Upstream>.Failure {
            let lock = Lock()
            var previous: Output? = nil
            
            self.upstream
                .tryFilter { (output) -> Bool in
                    try lock.withLock {
                        defer {
                            previous = output
                        }
                        
                        guard let prev = previous else {
                            previous = output
                            return true
                        }
                        
                        return try !self.predicate(prev, output)
                    }
                }
                .receive(subscriber: subscriber)
        }
    }
}
