extension Publisher where Self.Failure == Never {
    
    /// Creates a connectable wrapper around the publisher.
    ///
    /// - Returns: A `ConnectablePublisher` wrapping this publisher.
    public func makeConnectable() -> Publishers.MakeConnectable<Self> {
        return .init(self)
    }
}

extension Publishers {
    
    public struct MakeConnectable<Upstream> : ConnectablePublisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        private let multicase: Multicast<Upstream, PassthroughSubject<Output, Failure>>
        init(_ upstream: Upstream) {
            self.multicase = upstream.multicast(subject: PassthroughSubject<Output, Failure>())
        }
        
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.multicase.receive(subscriber: subscriber)
        }
        
        /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
        ///
        /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
        public func connect() -> Cancellable {
            return self.multicase.connect()
        }
    }
}
