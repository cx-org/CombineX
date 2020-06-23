#if !COCOAPODS
import CXUtility
#endif

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
    public struct Print<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// A string with which to prefix all log messages.
        public let prefix: String
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public let stream: TextOutputStream?
        
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
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.Print {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Print<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        
        let prefix: String
        let sub: Sub
        var stream: TextOutputStream
        
        var state: RelayState = .waiting
        
        init(pub: Pub, sub: Sub) {
            self.prefix = pub.prefix
            self.stream = pub.stream ?? ConsoleOutputStream()
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        private func write(_ string: String) {
            self.lock.withLock {
                self.stream.write("")
                self.stream.write(self.prefix + ": \(string)")
                self.stream.write("\n")
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.write("request \(demand.toText())")
            self.lock.withLockGet(self.state.subscription)?.request(demand)
        }
        
        func cancel() {
            self.write("receive cancel")
            self.lock.withLockGet(self.state.complete())?.cancel()
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            
            self.write("receive subscription: (\(subscription))")
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.lock.withLockGet(self.state.isRelaying) else {
                return .none
            }
            
            self.write("receive value: (\(input))")
            let demand = sub.receive(input)
            self.write("request \(demand.toText()) (synchronous)")
            
            return demand
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            
            switch completion {
            case .finished:
                self.write("receive finished")
            case .failure(let e):
                self.write("receive error: \(e)")
            }
            
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Print"
        }
        
        var debugDescription: String {
            return "Print"
        }
    }
}

private extension Subscribers.Demand {
    
    func toText() -> String {
        if let max = self.max {
            return "max: (\(max))"
        }
        return "unlimited"
    }
}

private struct ConsoleOutputStream: TextOutputStream {
    
    func write(_ string: String) {
        print(string, terminator: "")
    }
}
