extension Publisher {
    
    public func buffer(size: Int, prefetch: Publishers.PrefetchStrategy, whenFull: Publishers.BufferingStrategy<Self.Failure>) -> Publishers.Buffer<Self> {
        return .init(upstream: self, size: size, prefetch: prefetch, whenFull: whenFull)
    }
}

extension Publishers.PrefetchStrategy : Equatable { }

extension Publishers.PrefetchStrategy : Hashable { }

extension Publishers {
    
    public enum PrefetchStrategy {
        
        case keepFull
        
        case byRequest
        
        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: Publishers.PrefetchStrategy, b: Publishers.PrefetchStrategy) -> Bool {
            switch (a, b) {
            case (.keepFull, .keepFull):
                return true
            case (.byRequest, .byRequest):
                return true
            default:
                return false
            }
        }
        
        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
//        public var hashValue: Int { get }
        
        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
        ///   compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .keepFull:
                hasher.combine(0)
            case .byRequest:
                hasher.combine(1)
            }
        }
    }
    
    public enum BufferingStrategy<Failure> where Failure : Error {
        
        case dropNewest
        
        case dropOldest
        
        case customError(() -> Failure)
    }
    
    public struct Buffer<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let size: Int
        
        public let prefetch: Publishers.PrefetchStrategy
        
        public let whenFull: Publishers.BufferingStrategy<Upstream.Failure>
        
        public init(upstream: Upstream, size: Int, prefetch: Publishers.PrefetchStrategy, whenFull: Publishers.BufferingStrategy<Publishers.Buffer<Upstream>.Failure>) {
            self.upstream = upstream
            self.size = size
            self.prefetch = prefetch
            self.whenFull = whenFull
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
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
    
    private final class KeepFull<S>:
        Subscriber,
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Buffer<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        
        let sub: Sub
        let size: Int
        let whenFull: Publishers.BufferingStrategy<Upstream.Failure>
        
        var demand: Subscribers.Demand = .none
        
        var buffer: Queue<Output> = Queue()
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.size = pub.size
            self.whenFull = pub.whenFull
            self.sub = sub
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
            self.buffer = Queue()
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
                        
                        self.buffer = Queue()
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
            
            self.buffer = Queue()
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
    
    private final class ByRequest<S>:
        Subscriber,
        Subscription,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Buffer<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        
        let sub: Sub
        let size: Int
        let whenFull: Publishers.BufferingStrategy<Upstream.Failure>
        
        var demand: Subscribers.Demand = .none
        var buffer = Queue<Output>()
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            precondition(pub.size > 0)
            self.size = pub.size
            self.whenFull = pub.whenFull
            self.sub = sub
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
            self.buffer = Queue()
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
                        self.buffer = Queue()
                        
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
            
            self.buffer = Queue()
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
