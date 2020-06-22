#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Handles errors from an upstream publisher by either replacing it with another publisher or
    /// `throw`ing  a new error.
    ///
    /// - Parameter handler: A `throw`ing closure that accepts the upstream failure as input and
    /// returns a publisher to replace the upstream publisher or if an error is thrown will send the error
    /// downstream.
    /// - Returns: A publisher that handles errors from an upstream publisher by replacing the failed
    /// publisher with another publisher.
    public func tryCatch<P: Publisher>(_ handler: @escaping (Failure) throws -> P) -> Publishers.TryCatch<Self, P> where Output == P.Output {
        return .init(upstream: self, handler: handler)
    }
}

extension Publishers {
    
    /// A publisher that handles errors from an upstream publisher by replacing the failed publisher with
    /// another publisher or optionally producing a new error.
    public struct TryCatch<Upstream: Publisher, NewPublisher: Publisher>: Publisher where Upstream.Output == NewPublisher.Output {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Error
        
        public let upstream: Upstream
        
        public let handler: (Upstream.Failure) throws -> NewPublisher
        
        public init(upstream: Upstream, handler: @escaping (Upstream.Failure) throws -> NewPublisher) {
            self.upstream = upstream
            self.handler = handler
        }
        
        public func receive<S: Subscriber>(subscriber: S) where NewPublisher.Output == S.Input, S.Failure == Publishers.TryCatch<Upstream, NewPublisher>.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream
                .mapError { $0 }
                .receive(subscriber: s)
        }
    }
}

extension Publishers.TryCatch {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == NewPublisher.Output,
        S.Failure == Error {
        
        typealias Input = NewPublisher.Output
        typealias Failure = Error
        
        typealias Pub = Publishers.TryCatch<Upstream, NewPublisher>
        typealias Sub = S
        typealias Handler = (Upstream.Failure) throws -> NewPublisher
        
        enum Stage {
            case upstream
            case halftime
            case newPublisher
        }
        
        let lock = Lock()
        let sub: Sub
        let handler: Handler
        
        var state: RelayState = .waiting
        var demand: Subscribers.Demand = .none
        
        var stage = Stage.upstream
        
        init(pub: Pub, sub: Sub) {
            self.handler = pub.handler
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            guard let subscription = self.state.subscription else {
                self.lock.unlock()
                return
            }
            
            let old = self.demand
            self.demand += demand
            let new = self.demand
            
            self.lock.unlock()
            
            if old == 0 {
                subscription.request(new)
            }
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
        }
        
        func receive(subscription: Subscription) {
            self.lock.lock()
            switch self.state {
            case .waiting:
                self.state = .relaying(subscription)
                self.lock.unlock()
                self.sub.receive(subscription: self)
            case .relaying:
                switch self.stage {
                case .upstream, .newPublisher:
                    self.lock.unlock()
                    subscription.cancel()
                case .halftime:
                    self.stage = .newPublisher
                    self.state = .relaying(subscription)
                    let demand = self.demand
                    self.lock.unlock()
                    
                    subscription.request(demand)
                }
            case .completed:
                self.lock.unlock()
                subscription.cancel()
            }
        }
        
        func receive(_ input: NewPublisher.Output) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            self.demand -= 1
            self.lock.unlock()
            
            let new = self.sub.receive(input)
            self.lock.withLock {
                self.demand += new
            }
            return new
        }
        
        func receive(completion: Subscribers.Completion<Error>) {
            switch completion {
            case .finished:
                guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                    return
                }
                
                subscription.cancel()
                self.sub.receive(completion: completion)
            case .failure(let error):
                self.lock.lock()
                guard self.state.isRelaying else {
                    self.lock.unlock()
                    return
                }
                switch self.stage {
                case .upstream:
                    self.stage = .halftime
                    self.lock.unlock()
                    
                    do {
                        let newPublisher = try self.handler(error as! Upstream.Failure)
                        newPublisher.mapError { $0 } .subscribe(self)
                    } catch let e {
                        guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                            return
                        }
                        subscription.cancel()
                        self.sub.receive(completion: .failure(e))
                    }
                case .newPublisher:
                    let subscription = self.state.complete()!
                    self.lock.unlock()
                    
                    subscription.cancel()
                    self.sub.receive(completion: completion)
                case .halftime:
                    self.lock.unlock()
                }
            }
        }
        
        var description: String {
            return "TryCatch"
        }
        
        var debugDescription: String {
            return "TryCatch"
        }
    }
}
