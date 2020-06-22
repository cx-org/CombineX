#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Calls an error-throwing closure with each received element and publishes any returned optional that has a value.
    ///
    /// If the closure throws an error, the publisher cancels the upstream and sends the thrown error to the downstream receiver as a `Failure`.
    /// - Parameter transform: an error-throwing closure that receives a value and returns an optional value.
    /// - Returns: A publisher that republishes all non-`nil` results of calling the transform closure.
    public func tryCompactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Publishers.TryCompactMap<Self, T> {
        return .init(upstream: self, transform: transform)
    }
}

extension Publishers.TryCompactMap {
    
    public func compactMap<T>(_ transform: @escaping (Output) throws -> T?) -> Publishers.TryCompactMap<Upstream, T> {
        return self.upstream.tryCompactMap {
            try self.transform($0).flatMap(transform)
        }
    }
}

extension Publishers {
    
    /// A publisher that republishes all non-`nil` results of calling an error-throwing closure with each received element.
    public struct TryCompactMap<Upstream: Publisher, Output>: Publisher {
        
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// An error-throwing closure that receives values from the upstream publisher and returns optional values.
        ///
        /// If this closure throws an error, the publisher fails.
        public let transform: (Upstream.Output) throws -> Output?
        
        public init(upstream: Upstream, transform: @escaping (Upstream.Output) throws -> Output?) {
            self.upstream = upstream
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.TryCompactMap<Upstream, Output>.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.TryCompactMap {
    
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
        
        typealias Pub = Publishers.TryCompactMap<Upstream, Output>
        typealias Sub = S
        typealias Transform = (Upstream.Output) throws -> Output?
        
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
            self.lock.lock()
            self.state.preconditionValue()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            self.lock.unlock()
            
            do {
                if let transformed = try self.transform(input) {
                    return self.sub.receive(transformed)
                } else {
                    return .max(1)
                }
            } catch {
                self.complete(.failure(error))
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.complete(completion.mapError { $0 })
        }
        
        private func complete(_ completion: Subscribers.Completion<Error>) {
            self.lock.lock()
            self.state.preconditionCompletion()
            guard let subscription = self.state.complete() else {
                self.lock.unlock()
                return
            }
            self.lock.unlock()
            
            subscription.cancel()
            self.sub.receive(completion: completion.mapError { $0 })
        }
        
        var description: String {
            return "TryCompactMap"
        }
        
        var debugDescription: String {
            return "TryCompactMap"
        }
    }
}
