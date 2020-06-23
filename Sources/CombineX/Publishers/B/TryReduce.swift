#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Applies an error-throwing closure that accumulates each element of a stream and publishes a final result upon completion.
    ///
    /// If the closure throws an error, the publisher fails, passing the error to its subscriber.
    /// - Parameters:
    ///   - initialResult: The value the closure receives the first time it is called.
    ///   - nextPartialResult: An error-throwing closure that takes the previously-accumulated value and the next element from the upstream publisher to produce a new value.
    /// - Returns: A publisher that applies the closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public func tryReduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Output) throws -> T) -> Publishers.TryReduce<Self, T> {
        return .init(upstream: self, initial: initialResult, nextPartialResult: nextPartialResult)
    }
}

extension Publishers {
    
    /// A publisher that applies an error-throwing closure to all received elements and produces an accumulated value when the upstream publisher finishes.
    public struct TryReduce<Upstream: Publisher, Output>: Publisher {
        
        public typealias Failure = Error
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The initial value provided on the first invocation of the closure.
        public let initial: Output
        
        /// An error-throwing closure that takes the previously-accumulated value and the next element from the upstream to produce a new value.
        ///
        /// If this closure throws an error, the publisher fails and passes the error to its subscriber.
        public let nextPartialResult: (Output, Upstream.Output) throws -> Output
        
        public init(upstream: Upstream, initial: Output, nextPartialResult: @escaping (Output, Upstream.Output) throws -> Output) {
            self.upstream = upstream
            self.initial = initial
            self.nextPartialResult = nextPartialResult
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, S.Failure == Publishers.TryReduce<Upstream, Output>.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.TryReduce {
    
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
        
        typealias Pub = Publishers.TryReduce<Upstream, Output>
        typealias Sub = S
        
        typealias NextPartialResult = (Output, Upstream.Output) throws -> Output
        
        let lock = Lock()
        let nextPartialResult: NextPartialResult
        let sub: Sub
        
        var state: RelayState = .waiting
        var output: Output
        
        init(pub: Pub, sub: Sub) {
            self.nextPartialResult = pub.nextPartialResult
            self.sub = sub
            
            self.output = pub.initial
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            self.lock.withLockGet(self.state.subscription)?.request(.unlimited)
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
                let next = try self.nextPartialResult(self.output, input)
                self.output = next
                self.lock.unlock()
            } catch {
                let subscription = self.state.complete()
                self.lock.unlock()
                
                subscription?.cancel()
                self.sub.receive(completion: .failure(error))
            }

            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            
            switch completion {
            case .failure(let e):
                self.sub.receive(completion: .failure(e))
            case .finished:
                _ = self.sub.receive(self.output)
                self.sub.receive(completion: .finished)
            }
        }
        
        var description: String {
            return "TryReduce"
        }
        
        var debugDescription: String {
            return "TryReduce"
        }
    }
}
