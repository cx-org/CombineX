#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Replaces an empty stream with the provided element.
    ///
    /// If the upstream publisher finishes without producing any elements, this publisher emits the provided element, then finishes normally.
    /// - Parameter output: An element to emit when the upstream publisher finishes without emitting any elements.
    /// - Returns: A publisher that replaces an empty stream with the provided output element.
    public func replaceEmpty(with output: Output) -> Publishers.ReplaceEmpty<Self> {
        return .init(upstream: self, output: output)
    }
}

extension Publishers.ReplaceEmpty: Equatable where Upstream: Equatable, Upstream.Output: Equatable {}

extension Publishers {
    
    /// A publisher that replaces an empty stream with a provided element.
    public struct ReplaceEmpty<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The element to deliver when the upstream publisher finishes without delivering any elements.
        public let output: Upstream.Output
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        public init(upstream: Upstream, output: Publishers.ReplaceEmpty<Upstream>.Output) {
            self.upstream = upstream
            self.output = output
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.ReplaceEmpty {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Upstream.Output,
        S.Failure == Failure {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.ReplaceEmpty<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        let output: Upstream.Output
        let sub: Sub
        
        var isEmpty = true
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.output = pub.output
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            self.lock.withLockGet(self.state.subscription)?.request(demand)
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            self.isEmpty = false
            self.lock.unlock()
            
            return self.sub.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            guard let subscription = self.state.complete() else {
                self.lock.unlock()
                return
            }
            let isEmpty = self.isEmpty
            self.lock.unlock()
            
            subscription.cancel()
            if isEmpty {
                _ = self.sub.receive(self.output)
            }
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "ReplaceEmpty"
        }
        
        var debugDescription: String {
            return "ReplaceEmpty"
        }
    }
}
