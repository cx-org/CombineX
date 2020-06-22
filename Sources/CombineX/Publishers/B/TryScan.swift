#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Transforms elements from the upstream publisher by providing the current element to an error-throwing closure along with the last value returned by the closure.
    ///
    /// If the closure throws an error, the publisher fails with the error.
    /// - Parameters:
    ///   - initialResult: The previous result returned by the `nextPartialResult` closure.
    ///   - nextPartialResult: An error-throwing closure that takes as its arguments the previous value returned by the closure and the next element emitted from the upstream publisher.
    /// - Returns: A publisher that transforms elements by applying a closure that receives its previous return value and the next element from the upstream publisher.
    public func tryScan<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T) -> Publishers.TryScan<Self, T> {
        return .init(upstream: self, initialResult: initialResult, nextPartialResult: nextPartialResult)
    }
}

extension Publishers {
    
    public struct TryScan<Upstream: Publisher, Output>: Publisher {
        
        public typealias Failure = Error
        
        public let upstream: Upstream
        
        public let initialResult: Output
        
        public let nextPartialResult: (Output, Upstream.Output) throws -> Output
        
        public init(upstream: Upstream, initialResult: Output, nextPartialResult: @escaping (Output, Upstream.Output) throws -> Output) {
            self.upstream = upstream
            self.initialResult = initialResult
            self.nextPartialResult = nextPartialResult
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.TryScan<Upstream, Output>.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.receive(subscriber: s)
        }
    }
}

extension Publishers.TryScan {
    
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
        
        typealias Pub = Publishers.TryScan<Upstream, Output>
        typealias Sub = S
        typealias NextPartialResult = (Output, Upstream.Output) throws -> Output
        
        let lock = Lock()
        let nextPartialResult: NextPartialResult
        let sub: Sub
        
        var output: Output
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.nextPartialResult = pub.nextPartialResult
            self.sub = sub
            
            self.output = pub.initialResult
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
                let output = try self.nextPartialResult(self.output, input)
                self.output = output
                self.lock.unlock()
                
                return self.sub.receive(output)
            } catch {
                let subscription = self.state.complete()
                self.lock.unlock()
                
                subscription?.cancel()
                self.sub.receive(completion: .failure(error))
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion.mapError { $0 })
        }
        
        var description: String {
            return "TryScan"
        }
        
        var debugDescription: String {
            return "TryScan"
        }
    }
}
