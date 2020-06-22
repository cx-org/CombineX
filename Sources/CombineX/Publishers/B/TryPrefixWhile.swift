#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Republishes elements while a error-throwing predicate closure indicates publishing should continue.
    ///
    /// The publisher finishes when the closure returns `false`. If the closure throws, the publisher fails with the thrown error.
    ///
    /// - Parameter predicate: A closure that takes an element as its parameter and returns a Boolean value indicating whether publishing should continue.
    /// - Returns: A publisher that passes through elements until the predicate throws or indicates publishing should finish.
    public func tryPrefix(while predicate: @escaping (Output) throws -> Bool) -> Publishers.TryPrefixWhile<Self> {
        return .init(upstream: self, predicate: predicate)
    }
}

extension Publishers {
    
    /// A publisher that republishes elements while an error-throwing predicate closure indicates publishing should continue.
    public struct TryPrefixWhile<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The error-throwing closure that determines whether publishing should continue.
        public let predicate: (Upstream.Output) throws -> Bool
        
        public init(upstream: Upstream, predicate: @escaping (Publishers.TryPrefixWhile<Upstream>.Output) throws -> Bool) {
            self.upstream = upstream
            self.predicate = predicate
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Output == S.Input, S.Failure == Publishers.TryPrefixWhile<Upstream>.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.TryPrefixWhile {
    
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
        
        typealias Pub = Publishers.TryPrefixWhile<Upstream>
        typealias Sub = S
        typealias Predicate = (Upstream.Output) throws -> Bool
        
        let lock = Lock()
        let predicate: Predicate
        let sub: Sub
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.predicate = pub.predicate
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
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            do {
                if try self.predicate(input) {
                    self.lock.unlock()
                    return self.sub.receive(input)
                } else {
                    let subscription = self.state.complete()
                    self.lock.unlock()
                    
                    subscription?.cancel()
                    self.sub.receive(completion: .finished)
                    return .none
                }
            } catch {
                let subscription = self.state.complete()
                self.lock.unlock()
                
                subscription?.cancel()
                self.sub.receive(completion: .failure(error))
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.complete(completion.mapError { $0 })
        }
        
        private func complete(_ completion: Subscribers.Completion<Error>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion.mapError { $0 })
        }
        
        var description: String {
            return "TryPrefixWhile"
        }
        
        var debugDescription: String {
            return "TryPrefixWhile"
        }
    }
}
