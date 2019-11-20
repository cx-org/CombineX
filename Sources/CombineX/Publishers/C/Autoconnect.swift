extension ConnectablePublisher {
    
    /// Automates the process of connecting or disconnecting from this connectable publisher.
    ///
    /// Use `autoconnect()` to simplify working with `ConnectablePublisher` instances, such as those created with `makeConnectable()`.
    ///
    ///     let autoconnectedPublisher = somePublisher
    ///         .makeConnectable()
    ///         .autoconnect()
    ///         .subscribe(someSubscriber)
    ///
    /// - Returns: A publisher which automatically connects to its upstream connectable publisher.
    public func autoconnect() -> Publishers.Autoconnect<Self> {
        return .init(upstream: self)
    }
}

extension Publishers {
    
    /// A publisher that automatically connects and disconnects from this connectable publisher.
    public class Autoconnect<Upstream>: Publisher where Upstream: ConnectablePublisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public final let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var cancel: Cancellable?
            self.upstream
                .handleEvents(
                    receiveSubscription: { _ in
                        cancel = self.upstream.connect()
                    }, receiveCancel: {
                        cancel?.cancel()
                        cancel = nil
                    }
                )
                .receive(subscriber: subscriber)
        }
    }
}
