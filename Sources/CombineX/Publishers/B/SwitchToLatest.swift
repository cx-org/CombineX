extension Publisher where Self.Failure == Self.Output.Failure, Self.Output : Publisher {
    
    /// Flattens the stream of events from multiple upstream publishers to appear as if they were coming from a single stream of events.
    ///
    /// This operator switches the inner publisher as new ones arrive but keeps the outer one constant for downstream subscribers.
    /// For example, given the type `Publisher<Publisher<Data, NSError>, Never>`, calling `switchToLatest()` will result in the type `Publisher<Data, NSError>`. The downstream subscriber sees a continuous stream of values even though they may be coming from different upstream publishers.
    public func switchToLatest() -> Publishers.SwitchToLatest<Self.Output, Self> {
        return .init(upstream: self)
    }
}

extension Publishers {
    
    /// A publisher that “flattens” nested publishers.
    ///
    /// Given a publisher that publishes Publishers, the `SwitchToLatest` publisher produces a sequence of events from only the most recent one.
    /// For example, given the type `Publisher<Publisher<Data, NSError>, Never>`, calling `switchToLatest()` will result in the type `Publisher<Data, NSError>`. The downstream subscriber sees a continuous stream of values even though they may be coming from different upstream publishers.
    public struct SwitchToLatest<P, Upstream> : Publisher where P : Publisher, P == Upstream.Output, Upstream : Publisher, P.Failure == Upstream.Failure {
        
        /// The kind of values published by this publisher.
        public typealias Output = P.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = P.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// Creates a publisher that “flattens” nested publishers.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, P.Output == S.Input, Upstream.Failure == S.Failure {
            let s = Inner(sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.SwitchToLatest {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == P.Output,
        S.Failure == P.Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.SwitchToLatest<P, Upstream>
        typealias Sub = S
        
        // for upstream
        let upLock = Lock()
        var upState: RelayState = .waiting
        
        // for downstream
        let downLock = Lock()
        let sub: Sub

        var downState: DemandState = .waiting
        var child: Child?
        
        init(sub: Sub) {
            self.sub = sub
        }
        
        // MARK: Subscription
        func request(_ demand: Subscribers.Demand) {
            self.downLock.lock()
            switch self.downState {
            case .waiting:
                self.downState = .demanding(demand)
                
                let child = self.child
                self.downLock.unlock()
                
                child?.request(demand)
            case .demanding(let old):
                let new = old + demand
                self.downState = .demanding(new)
                
                let child = self.child
                self.downLock.unlock()
                
                child?.request(demand)
            default:
                self.downLock.unlock()
            }
        }
        
        func cancel() {
            self.downLock.lock()
            guard self.downState.complete() else {
                self.downLock.unlock()
                return
            }
            
            let child = self.child
            self.child = nil
            self.downLock.unlock()
            
            child?.cancel()
            self.upLock.withLockGet(self.upState.complete())?.cancel()
        }
        
        // MARK: Subscriber
        func receive(subscription: Subscription) {
            guard self.upLock.withLockGet(self.upState.relay(subscription)) else {
                subscription.cancel()
                return
            }
            self.sub.receive(subscription: self)
            subscription.request(.unlimited)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.upLock.withLockGet(self.upState.isRelaying) else {
                return .none
            }
            
            let new = Child(parent: self)
            
            self.downLock.lock()
            if self.downState.isCompleted {
                self.downLock.unlock()
                return .none
            }
            
            let old = self.child
            let demand = self.downState.demand
            self.child = new
            self.downLock.unlock()
            
            old?.cancel()
            input.subscribe(new)
            
            if let demand = demand {
                new.request(demand)
            }
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.upLock.withLockGet(self.upState.complete()) else {
                return
            }
            subscription.cancel()

            switch completion {
            case .finished:
                self.downLock.lock()
                if self.child == nil {
                    guard self.downState.complete() else {
                        self.downLock.unlock()
                        return
                    }
                    self.downLock.unlock()
                    self.sub.receive(completion: .finished)
                } else {
                    self.downLock.unlock()
                }
            case .failure(let error):
                self.downLock.lock()
                guard self.downState.complete() else {
                    self.downLock.unlock()
                    return
                }
                
                let child = self.child
                self.child = nil
                self.downLock.unlock()
                
                child?.cancel()

                self.sub.receive(completion: .failure(error))
            }
        }
        
        // MARK: ChildSubsciber
        private func receive(_ input: P.Output, from child: Child) -> Subscribers.Demand {
            self.downLock.lock()
            guard let old = self.downState.demand, old > 0 else {
                self.downLock.unlock()
                return .none
            }
            
            _ = self.downState.sub(.max(1))
            self.downLock.unlock()
            
            let more = self.sub.receive(input)
            
            self.downLock.lock()
            _ = self.downState.add(more)
            self.downLock.unlock()
            
            return more
        }
        
        private func receive(completion: Subscribers.Completion<P.Failure>, from child: Child) {
            self.downLock.lock()
            guard self.downState.isDemanding else {
                self.downLock.unlock()
                return
            }
            
            if self.child === child {
                self.child = nil
            }
            
            switch completion {
            case .finished:
                if self.upLock.withLockGet(self.upState.isCompleted) {
                    self.downState = .completed
                    self.downLock.unlock()
                    
                    self.sub.receive(completion: .finished)
                } else {
                    self.downLock.unlock()
                }
            case .failure(let error):
                self.downState = .completed
                self.downLock.unlock()
                
                self.sub.receive(completion: .failure(error))
                
                self.upLock.withLockGet(self.upState.complete())?.cancel()
            }
        }
        
        var description: String {
            return "SwitchToLatest"
        }
        
        var debugDescription: String {
            return "SwitchToLatest"
        }
        
        final class Child: Subscriber {
            
            typealias Input = P.Output
            typealias Failure = P.Failure
            
            let parent: Inner
            
            let subscription = Atom<Subscription?>(val: nil)
            
            init(parent: Inner) {
                self.parent = parent
            }
            
            func receive(subscription: Subscription) {
                if self.subscription.setIfNil(subscription) {
                    subscription.request(.max(1))
                } else {
                    subscription.cancel()
                }
            }
            
            func receive(_ input: P.Output) -> Subscribers.Demand {
                guard self.subscription.isNotNil else {
                    return .none
                }
                return self.parent.receive(input, from: self)
            }
            
            func receive(completion: Subscribers.Completion<P.Failure>) {
                guard let subscription = self.subscription.exchange(with: nil) else {
                    return
                }
                
                subscription.cancel()
                self.parent.receive(completion: completion, from: self)
            }
            
            func cancel() {
                self.subscription.exchange(with: nil)?.cancel()
            }
            
            func request(_ demand: Subscribers.Demand) {
                self.subscription.get()?.request(demand)
            }
        }
    }
}
