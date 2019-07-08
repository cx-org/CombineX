extension Publisher where Self.Output : Equatable {
    
    /// Publishes only elements that don’t match the previous element.
    ///
    /// - Returns: A publisher that consumes — rather than publishes — duplicate elements.
    public func removeDuplicates() -> Publishers.RemoveDuplicates<Self> {
        return .init(upstream: self, predicate: ==)
    }
}

extension Publisher {
    
    public func removeDuplicates(by predicate: @escaping (Self.Output, Self.Output) -> Bool) -> Publishers.RemoveDuplicates<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    public struct RemoveDuplicates<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let predicate: (Upstream.Output, Upstream.Output) -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Publishers.RemoveDuplicates<Upstream>.Output, Publishers.RemoveDuplicates<Upstream>.Output) -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.upstream
                .tryRemoveDuplicates(by: self.predicate)
                .mapError {
                    $0 as! Failure
                }
                .receive(subscriber: subscriber)
        }
    }
}
