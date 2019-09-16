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
    public class Autoconnect<Upstream> : Publisher where Upstream : ConnectablePublisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        final public let upstream: Upstream
        
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            var cancel: Cancellable?
            self.upstream
                .handleEvents(
                    receiveSubscription: { (_) in
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
