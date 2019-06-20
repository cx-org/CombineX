extension Publisher {
    
    /// Transforms all elements from an upstream publisher into a new or existing publisher.
    ///
    /// `flatMap` merges the output from all returned publishers into a single stream of output.
    ///
    /// - Parameters:
    ///   - maxPublishers: The maximum number of publishers produced by this method.
    ///   - transform: A closure that takes an element as a parameter and returns a publisher
    /// that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream publisher into
    /// a publisher of that element’s type.
    public func flatMap<T, P>(maxPublishers: Subscribers.Demand = .unlimited, _ transform: @escaping (Self.Output) -> P) -> Publishers.FlatMap<P, Self> where T == P.Output, P : Publisher, Self.Failure == P.Failure {
        return Publishers.FlatMap(upstream: self, maxPublishers: maxPublishers, transform: transform)
    }
}

extension Publishers {
    
    public struct FlatMap<P, Upstream> : Publisher where P : Publisher, Upstream : Publisher, P.Failure == Upstream.Failure {
        
        /// The kind of values published by this publisher.
        public typealias Output = P.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let maxPublishers: Subscribers.Demand
        
        public let transform: (Upstream.Output) -> P
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, P.Output == S.Input, Upstream.Failure == S.Failure {
            let subscription = FlatMapSubscription(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.FlatMap {
    
    fileprivate final class FlatMapSubscription<S>:
        Subscription,
        Subscriber
    where
        S: Subscriber,
        S.Input == P.Output,
        S.Failure == P.Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        let lock = Lock(recursive: true)
        
        // for upstream
        let upstreamState = Atomic<RelaySubscriberState>(value: .waiting)
        var children: [ChildSubscriber] = []
        
        // for downstream
        let downstreamState = Atomic<SubscriptionState>(value: .waiting)
        var buffer = CircularBuffer<P.Output>()
        
        typealias Pub = Publishers.FlatMap<P, Upstream>
        typealias Sub = S
        
        var pub: Pub?
        var sub: Sub?
        
        let maxPublishers: Subscribers.Demand
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
            
            self.maxPublishers = pub.maxPublishers
        }
        
        func drain() {
            if let demand = self.downstreamState.demand {
                switch demand {
                case .unlimited:
                    self.fastPath()
                case .max:
                    self.slowPath(demand)
                }
            }
        }
        
        func fastPath() {
            var buffer = self.downstreamState.withLockVoid { () -> CircularBuffer<P.Output> in
                let copy = self.buffer
                self.buffer = CircularBuffer<P.Output>()
                return copy
            }

            while let next = buffer.popFirst() {
                guard self.downstreamState.isSubscribing else {
                    return
                }
                _ = self.sub?.receive(next)
            }
            
            let upstreamDone = self.upstreamState.withLock {
                $0.isFinished && self.children.isEmpty
            }
            
            if upstreamDone {
                guard self.downstreamState.isSubscribing else {
                    return
                }
                self.sub?.receive(completion: .finished)
                
                self.pub = nil
                self.sub = nil
            }
        }
        
        func slowPath(_ demand: Subscribers.Demand) {
            guard demand < .unlimited else {
                self.fastPath()
                return
            }
            
            let sendFinishIfDone = {
                let done = self.upstreamState.withLock {
                    $0.isFinished && self.children.isEmpty
                }
                
                if done {
                    self.sub?.receive(completion: .finished)
                    
                    self.pub = nil
                    self.sub = nil
                }
            }

            var totalDemand = demand
            while totalDemand > 0 {
                guard let element = self.downstreamState.withLockVoid({ self.buffer.popFirst() }) else {
                    
                    sendFinishIfDone()
                    
                    return
                }
                
                guard self.downstreamState.isSubscribing else {
                    return
                }

                let demand = self.sub?.receive(element) ?? .none
                guard let currentDemand = self.downstreamState.tryAdd(demand - 1)?.after, currentDemand > 0 else {
                    
                    if self.buffer.isEmpty {
                        sendFinishIfDone()
                    }
                    
                    return
                }
                
                totalDemand = currentDemand
                
                if totalDemand == .unlimited {
                    self.fastPath()
                    return
                }
            }
        }
        
        // MARK: Subscription
        func request(_ demand: Subscribers.Demand) {
            if self.downstreamState.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {

                switch demand {
                case .unlimited:
                    self.fastPath()
                case .max(let amount):
                    if amount > 0 {
                        self.slowPath(demand)
                    }
                }
            } else if let demands = self.downstreamState.tryAdd(demand), demands.before <= 0 {
                self.slowPath(demands.after)
            }
        }
        
        func cancel() {
            self.upstreamState.finishIfSubscribing()?.cancel()
        
            self.pub = nil
            self.sub = nil
            
            let children = self.upstreamState.withLockVoid { () -> [ChildSubscriber] in
                let copy = self.children
                self.children = []
                return copy
            }
            
            for child in children {
                child.subscription.exchange(with: nil)?.cancel()
            }
            
            self.downstreamState.withLockVoid {
                self.buffer = CircularBuffer()
            }
        }
        
        // MARK: ChildSubsciber
        func receive(_ input: P.Output, from child: ChildSubscriber) -> Subscribers.Demand {
            guard self.downstreamState.isSubscribing else {
                return .none
            }
            
            self.downstreamState.withLockVoid {
                self.buffer.append(input)
            }
            
            self.drain()
            return .max(1)
        }
        
        func receive(completion: Subscribers.Completion<P.Failure>, from child: ChildSubscriber) {
            guard self.downstreamState.isSubscribing else {
                return
            }

            switch completion {
            case .finished:
                self.upstreamState.withLockVoid {
                    self.children.removeAll(where: { $0 === child })
                }
                
                self.drain()
                self.upstreamState.subscription?.request(.max(1))
            case .failure(let error):
                
                self.sub?.receive(completion: .failure(error))
                
                let children = self.upstreamState.withLockVoid { () -> [ChildSubscriber] in
                    let copy = self.children
                    self.children = []
                    return copy
                }
                
                for child in children {
                    child.subscription.exchange(with: nil)?.cancel()
                }
                
                self.downstreamState.withLockVoid {
                    self.buffer = CircularBuffer()
                }
                
                
                self.pub = nil
                self.sub = nil
            }
        }
        
        // MARK: Subscriber
        func receive(subscription: Subscription) {
            if upstreamState.compareAndStore(expected: .waiting, newVaue: .subscribing(subscription)) {
                self.sub?.receive(subscription: self)
                subscription.request(self.maxPublishers)
            } else {
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.upstreamState.isSubscribing else {
                return .none
            }
            
            guard let pub = self.pub else {
                return .none
            }
            
            let s = ChildSubscriber(parent: self)
            self.upstreamState.withLockVoid {
                self.children.append(s)
            }
            pub.transform(input).subscribe(s)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<P.Failure>) {
            if let subscription = self.upstreamState.finishIfSubscribing() {
                subscription.cancel()
                
                switch completion {
                case .finished:
                    self.drain()
                case .failure(let error):
                    self.sub?.receive(completion: .failure(error))
                    
                    let children = self.upstreamState.withLockVoid { () -> [ChildSubscriber] in
                        let copy = self.children
                        self.children = []
                        return copy
                    }
                    
                    for child in children {
                        child.subscription.exchange(with: nil)?.cancel()
                    }
                    
                    self.downstreamState.withLockVoid {
                        self.buffer = CircularBuffer()
                    }
                    
                    self.pub = nil
                    self.sub = nil
                }
            }
        }
        
        // MARK: - ChildSubscriber
        final class ChildSubscriber: Subscriber {
            
            typealias Input = P.Output
            typealias Failure = P.Failure
            
            let parent: FlatMapSubscription
            
            let subscription = Atomic<Subscription?>(value: nil)
            
            init(parent: FlatMapSubscription) {
                self.parent = parent
            }
            
            func receive(subscription: Subscription) {
                if Atomic.ifNil(self.subscription, store: subscription) {
                    subscription.request(.max(1))
                } else {
                    subscription.cancel()
                }
            }
            
            func receive(_ input: P.Output) -> Subscribers.Demand {
                if self.subscription.load() == nil {
                    return .none
                }
                return self.parent.receive(input, from: self)
            }
            
            func receive(completion: Subscribers.Completion<P.Failure>) {
                if let subscription = self.subscription.exchange(with: nil) {
                    subscription.cancel()
                    self.parent.receive(completion: completion, from: self)
                }
            }
        }
    }
}
