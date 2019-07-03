extension Publisher {
    
    /// Prints log messages for all publishing events.
    ///
    /// - Parameter prefix: A string with which to prefix all log messages. Defaults to an empty string.
    /// - Returns: A publisher that prints log messages for all publishing events.
    public func print(_ prefix: String = "", to stream: TextOutputStream? = nil) -> Publishers.Print<Self> {
        return .init(upstream: self, prefix: prefix, to: stream)
    }
}

extension Publishers {
    
    /// A publisher that prints log messages for all publishing events, optionally prefixed with a given string.
    ///
    /// This publisher prints log messages when receiving the following events:
    /// * subscription
    /// * value
    /// * normal completion
    /// * failure
    /// * cancellation
    public struct Print<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// A string with which to prefix all log messages.
        public let prefix: String
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public var stream: TextOutputStream?
        
        /// Creates a publisher that prints log messages for all publishing events.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives elements.
        ///   - prefix: A string with which to prefix all log messages.
        public init(upstream: Upstream, prefix: String, to stream: TextOutputStream? = nil) {
            self.upstream = upstream
            self.prefix = prefix
            self.stream = stream
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.Print {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Print<Upstream>
        typealias Sub = S
        
        let state = Atomic<RelayState>(value: .waiting)
        
        let streamLock = Lock()
        
        var upstream: Upstream?
        let prefix: String
        var stream: TextOutputStream
        
        var sub: Sub?
        
        init(pub: Pub, sub: Sub) {
            self.sub = sub
        
            self.upstream = pub.upstream
            self.prefix = pub.prefix
            self.stream = pub.stream ?? ConsoleOutputStream()
        }
        
        private func write(_ string: String) {
            var output = "\(self.prefix): \(string)\n"
            
            self.streamLock.lock()
            defer {
                self.streamLock.unlock()
            }
            
            self.stream.write(output)
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.write("request \(demand)")
            self.state.subscription?.request(demand)
        }
        
        func cancel() {
            self.write("receive cancel")
            self.state.finishIfRelaying()?.cancel()
            
            self.upstream = nil
//            self.sub = nil
        }
        
        func receive(subscription: Subscription) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .relaying(subscription)) {
                self.write("receive subscription: (\(subscription))")
                self.sub?.receive(subscription: self)
            } else {
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.state.isRelaying else {
                return .none
            }
            
            guard let sub = self.sub else {
                return .none
            }
            
            self.write("receive value: (\(input))")
            let demand = sub.receive(input)
            self.write("request \(demand) (synchronous)")
            
            return demand
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            if let subscription = self.state.finishIfRelaying() {
                subscription.cancel()
                
                switch completion {
                case .finished:
                    self.write("receive finished")
                case .failure(let e):
                    self.write("receive error: \(e)")
                }
                
                self.sub?.receive(completion: completion)
                self.upstream = nil
//                self.sub = nil
            }
        }
        
        var description: String {
            return "Print"
        }
        
        var debugDescription: String {
            return "Print"
        }
    }
}

private class ConsoleOutputStream: TextOutputStream {
    
    func write(_ string: String) {
        print(string, terminator: "")
    }
}
