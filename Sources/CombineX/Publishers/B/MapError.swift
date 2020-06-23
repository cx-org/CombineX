#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Converts any failure from the upstream publisher into a new error.
    ///
    /// Until the upstream publisher finishes normally or fails with an error, the returned publisher republishes all the elements it receives.
    ///
    /// - Parameter transform: A closure that takes the upstream failure as a parameter and returns a new error for the publisher to terminate with.
    /// - Returns: A publisher that replaces any upstream failure with a new error produced by the `transform` closure.
    public func mapError<E: Error>(_ transform: @escaping (Failure) -> E) -> Publishers.MapError<Self, E> {
        return .init(upstream: self, transform)
    }
}

extension Publishers {
    
    /// A publisher that converts any failure from the upstream publisher into a new error.
    public struct MapError<Upstream: Publisher, Failure: Error>: Publisher {
        
        public typealias Output = Upstream.Output
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The closure that converts the upstream failure into a new error.
        public let transform: (Upstream.Failure) -> Failure
        
        public init(upstream: Upstream, _ map: @escaping (Upstream.Failure) -> Failure) {
            self.upstream = upstream
            self.transform = map
        }
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Failure) -> Failure) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Upstream.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.MapError {
    
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
        
        typealias Pub = Publishers.MapError<Upstream, S.Failure>
        typealias Sub = S
        typealias Transform = (Upstream.Failure) -> S.Failure
        
        let lock = Lock()
        let transform: Transform
        let sub: Sub
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.transform = pub.transform
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
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
            guard self.lock.withLockGet(self.state.isRelaying) else {
                return .none
            }

            return self.sub.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion.mapError(self.transform))
        }
        
        var description: String {
            return "MapError"
        }
        
        var debugDescription: String {
            return "MapError"
        }
    }
}
