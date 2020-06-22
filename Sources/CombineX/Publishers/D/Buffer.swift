#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Buffers elements received from an upstream publisher.
    /// - Parameter size: The maximum number of elements to store.
    /// - Parameter prefetch: The strategy for initially populating the buffer.
    /// - Parameter whenFull: The action to take when the buffer becomes full.
    public func buffer(size: Int, prefetch: Publishers.PrefetchStrategy, whenFull: Publishers.BufferingStrategy<Failure>) -> Publishers.Buffer<Self> {
        return .init(upstream: self, size: size, prefetch: prefetch, whenFull: whenFull)
    }
}

extension Publishers {
    
    /// A strategy for filling a buffer.
    ///
    /// * keepFull: A strategy to fill the buffer at subscription time, and keep it full thereafter.
    /// * byRequest: A strategy that avoids prefetching and instead performs requests on demand.
    public enum PrefetchStrategy: Equatable, Hashable {
        
        case keepFull
        
        case byRequest
    }
    
    /// A strategy for handling exhaustion of a buffer’s capacity.
    ///
    /// * dropNewest: When full, discard the newly-received element without buffering it.
    /// * dropOldest: When full, remove the least recently-received element from the buffer.
    /// * customError: When full, execute the closure to provide a custom error.
    public enum BufferingStrategy<Failure: Error> {
        
        case dropNewest
        
        case dropOldest
        
        case customError(() -> Failure)
    }
    
    /// A publisher that buffers elements received from an upstream publisher.
    public struct Buffer<Upstream: Publisher>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The maximum number of elements to store.
        public let size: Int
        
        /// The strategy for initially populating the buffer.
        public let prefetch: Publishers.PrefetchStrategy
        
        /// The action to take when the buffer becomes full.
        public let whenFull: Publishers.BufferingStrategy<Upstream.Failure>
        
        /// Creates a publisher that buffers elements received from an upstream publisher.
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        /// - Parameter size: The maximum number of elements to store.
        /// - Parameter prefetch: The strategy for initially populating the buffer.
        /// - Parameter whenFull: The action to take when the buffer becomes full.
        public init(upstream: Upstream, size: Int, prefetch: Publishers.PrefetchStrategy, whenFull: Publishers.BufferingStrategy<Publishers.Buffer<Upstream>.Failure>) {
            self.upstream = upstream
            self.size = size
            self.prefetch = prefetch
            self.whenFull = whenFull
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            switch self.prefetch {
            case .keepFull:
                let subscription = KeepFull(pub: self, sub: subscriber)
                self.upstream.subscribe(subscription)
            case .byRequest:
                let s = ByRequest(pub: self, sub: subscriber)
                self.upstream.subscribe(s)
            }
        }
    }
}

// MARK: - KeepFull

extension Publishers.Buffer {
    
    private final class KeepFull<S>: Subscriber,
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Buffer<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        
        let sub: Sub
        let size: Int
        let whenFull: Publishers.BufferingStrategy<Upstream.Failure>
        
        var demand: Subscribers.Demand = .none
        
        var buffer: CircularBuffer<Output> = CircularBuffer()
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.size = pub.size
            self.whenFull = pub.whenFull
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
            let new = old + demand
            self.demand = new
            
             if old == 0, new > 0, !self.buffer.isEmpty {
                let count = self.drain(new)
                subscription.request(demand + count)
            } else {
                self.lock.unlock()
                subscription.request(demand)
            }
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
            self.buffer = CircularBuffer()
        }
        
        private func drain(_ demand: Subscribers.Demand) -> Int {
            // in locking
            var count = 0
            var now = demand
            while now > 0 {
                guard let output = self.buffer.popFirst() else {
                    self.lock.unlock()
                    return count
                }
                self.demand -= 1
                self.lock.unlock()
                
                count += 1
                let more = self.sub.receive(output)
                
                self.lock.lock()
                
                self.demand += more
                now = self.demand
            }
            
            self.lock.unlock()
            return count
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            
            subscription.request(.max(self.size))
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            if self.demand > 0 {
                self.demand -= 1
                self.lock.unlock()
                
                let more = self.sub.receive(input)
                
                self.lock.lock()
                self.demand += more
                self.lock.unlock()
                return .max(1)
            } else {
                let count = self.buffer.count
                switch count {
                case 0..<self.size:
                    self.buffer.append(input)
                    self.lock.unlock()
                case self.size:
                    switch self.whenFull {
                    case .dropOldest:
                        _ = self.buffer.popFirst()
                        self.buffer.append(input)
                        self.lock.unlock()
                    case .dropNewest:
                        self.lock.unlock()
                    case .customError(let makeError):
                        guard let subscription = self.state.complete() else {
                            self.lock.unlock()
                            return .none
                        }
                        self.lock.unlock()
                        
                        subscription.cancel()
                        
                        self.buffer = CircularBuffer()
                        self.sub.receive(completion: .failure(makeError()))
                    }
                default:
                    self.lock.unlock()
                }
            }
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            
            self.buffer = CircularBuffer()
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Buffer"
        }
        
        var debugDescription: String {
            return "Buffer"
        }
    }
}

// MARK: - ByRequest

extension Publishers.Buffer {
    
    private final class ByRequest<S>: Subscriber,
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Buffer<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        
        let sub: Sub
        let size: Int
        let whenFull: Publishers.BufferingStrategy<Upstream.Failure>
        
        var demand: Subscribers.Demand = .none
        var buffer = CircularBuffer<Output>()
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            precondition(pub.size > 0)
            self.size = pub.size
            self.whenFull = pub.whenFull
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
            let new = old + demand
            self.demand = new
            
            if old == 0, new > 0, !self.buffer.isEmpty {
                self.drain(new)
            } else {
                self.lock.unlock()
            }
            
            subscription.request(demand)
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
            self.buffer = CircularBuffer()
        }
        
        private func drain(_ demand: Subscribers.Demand) {
            // in locking
            var now = demand
            while now > 0 {
                guard let output = self.buffer.popFirst() else {
                    self.lock.unlock()
                    return
                }
                self.demand -= 1
                self.lock.unlock()
                
                let more = self.sub.receive(output)
                
                self.lock.lock()
                
                self.demand += more
                now = self.demand
            }
            
            self.lock.unlock()
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            
            subscription.request(.unlimited)
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            if self.demand > 0 {
                self.demand -= 1
                self.lock.unlock()
                
                let more = self.sub.receive(input)
                
                self.lock.withLock {
                    self.demand += more
                }
            } else {
                switch self.buffer.count {
                case 0..<self.size:
                    self.buffer.append(input)
                    self.lock.unlock()
                case self.size:
                    switch self.whenFull {
                    case .dropOldest:
                        _ = self.buffer.popFirst()
                        self.buffer.append(input)
                        self.lock.unlock()
                    case .dropNewest:
                        self.lock.unlock()
                    case .customError(let makeError):
                        let subscription = self.state.complete()!
                        self.lock.unlock()
                        
                        subscription.cancel()
                        self.buffer = CircularBuffer()
                        
                        self.sub.receive(completion: .failure(makeError()))
                    }
                default:
                    self.lock.unlock()
                }
            }
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            
            self.buffer = CircularBuffer()
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Buffer"
        }
        
        var debugDescription: String {
            return "Buffer"
        }
    }
}
