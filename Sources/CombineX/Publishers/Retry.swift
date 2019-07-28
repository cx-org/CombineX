extension Publisher {
    
    /// Attempts to recreate a failed subscription with the upstream publisher using a specified number of attempts to establish the connection.
    ///
    /// After exceeding the specified number of retries, the publisher passes the failure to the downstream receiver.
    /// - Parameter retries: The number of times to attempt to recreate the subscription.
    /// - Returns: A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public func retry(_ retries: Int) -> Publishers.Retry<Self> {
        return .init(upstream: self, retries: retries)
    }
}

extension Publishers.Retry : Equatable where Upstream : Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Publishers.Retry<Upstream>, rhs: Publishers.Retry<Upstream>) -> Bool {
        return lhs.upstream == rhs.upstream && lhs.retries == rhs.retries
    }
}

extension Publishers {
    
    /// A publisher that attempts to recreate its subscription to a failed upstream publisher.
    public struct Retry<Upstream> : Publisher where Upstream : Publisher {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The maximum number of retry attempts to perform.
        ///
        /// If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
        public let retries: Int?
        
        /// Creates a publisher that attempts to recreate its subscription to a failed upstream publisher.
        ///
        /// - Parameters:
        ///   - upstream: The publisher from which this publisher receives its elements.
        ///   - retries: The maximum number of retry attempts to perform. If `nil`, this publisher attempts to reconnect with the upstream publisher an unlimited number of times.
        public init(upstream: Upstream, retries: Int?) {
            self.upstream = upstream
            self.retries = retries
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            Global.RequiresImplementation()
//            let s = Inner(pub: self, sub: subscriber, retries: self.retries)
//            self.upstream.subscribe(s)
        }
    }
}

/*
 

extension Publishers.Retry {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Upstream.Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Retry<Upstream>
        typealias Sub = S
        
        let lock = Lock()
        let sub: Sub
        
        var state = RelayState.waiting
        var pub: Pub?
        var retries: Int?
        
        var demand: Subscribers.Demand = .none
        
        init(pub: Pub, sub: Sub, retries: Int?, initialDemand: Subscribers.Demand = .none) {
            self.pub = pub
            self.retries = retries
            self.sub = sub
            
            self.demand = initialDemand
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            guard let subscription = self.state.subscription else {
                self.lock.unlock()
                return
            }
            self.demand += demand
            self.lock.unlock()
            
            subscription.request(demand)
        }
        
        func cancel() {
            self.lock.lock()
            guard let subscription = self.state.complete() else {
                self.lock.unlock()
                return
            }
            
            self.pub = nil
            self.lock.unlock()
            
            subscription.cancel()
        }
        
        func receive(subscription: Subscription) {
            self.lock.lock()
            guard self.state.relay(subscription) else {
                self.lock.unlock()
                subscription.cancel()
                return
            }
            let demand = self.demand
            self.lock.unlock()
            
            self.sub.receive(subscription: self)
            
            if demand != 0 {
                subscription.request(demand)
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            
            self.demand -= 1
            self.lock.unlock()
            
            return self.sub.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                self.lock.unlock()
                return
            }
                
            switch completion {
            case .finished:
                self.pub = nil
                self.lock.unlock()
                subscription.cancel()
                self.sub.receive(completion: completion)
            case .failure:
                if let retries = self.retries {
                    if retries == 0 {
                        self.pub = nil
                        self.lock.unlock()
                        subscription.cancel()
                        self.sub.receive(completion: completion)
                    } else {
                        let pub = self.pub!
                        self.pub = nil
                        
                        let demand = self.demand
                        self.lock.lock()
                        subscription.cancel()
                        
                        let s = Inner(pub: pub, sub: self.sub, retries: retries - 1, initialDemand: demand)
                        pub.upstream.subscribe(s)
                    }
                } else {
                    let pub = self.pub!
                    self.pub = nil
                    
                    let demand = self.demand
                    self.lock.lock()
                    subscription.cancel()
                    
                    let s = Inner(pub: pub, sub: self.sub, retries: nil, initialDemand: demand)
                    pub.upstream.subscribe(s)
                    
                }
            }
            
            
        }
        
        var description: String {
            return "Retry"
        }
        
        var debugDescription: String {
            return "Retry"
        }
    }
}

 */
