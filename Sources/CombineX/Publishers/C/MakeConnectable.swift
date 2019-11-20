extension Publisher where Failure == Never {
    
    /// Creates a connectable wrapper around the publisher.
    ///
    /// - Returns: A `ConnectablePublisher` wrapping this publisher.
    public func makeConnectable() -> Publishers.MakeConnectable<Self> {
        return .init(self)
    }
}

extension Publishers {
    
    public struct MakeConnectable<Upstream>: ConnectablePublisher where Upstream: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        private let multicase: Multicast<Upstream, PassthroughSubject<Output, Failure>>
        init(_ upstream: Upstream) {
            self.multicase = upstream.multicast(subject: PassthroughSubject<Output, Failure>())
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            self.multicase.receive(subscriber: subscriber)
        }
        
        public func connect() -> Cancellable {
            return self.multicase.connect()
        }
    }
}
