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
        CustomSubscription<Publishers.FlatMap<P, Upstream>, S>,
        Subscriber
    where
        S: Subscriber,
        S.Input == P.Output,
        S.Failure == P.Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        // MARK: for upstream
        let subscription = Atomic<Subscription?>(value: nil)
        
        // MARK: for downstream
        let state = Atomic<SubscriptionState>(value: .waiting)
        let buffer = Atomic<[P.Output]>(value: [])
        
        let children = Atomic<[ChildSubscriber]>(value: [])
        
        func drain() {
            if let demand = self.state.demand {
                switch demand {
                case .unlimited:
                    self.fastPath()
                case .max:
                    self.slowPath(demand)
                }
            }
        }
        
        func fastPath() {
            var iterator = self.buffer.load().makeIterator()
            while let next = iterator.next() {
                guard self.state.isSubscribing else {
                    return
                }
                
                _ = self.sub.receive(next)
            }
            
            if self.state.isSubscribing {
                self.sub.receive(completion: .finished)
            }
        }
        
        func slowPath(_ demand: Subscribers.Demand) {
            var iterator = self.buffer.load().makeIterator()
            var totalDemand = demand
            
            while totalDemand > 0 {
                guard let element = iterator.next(), self.state.isSubscribing else {
                    return
                }
                
                let demand = self.sub.receive(element)
                guard let currentDemand = self.state.tryAdd(demand - 1)?.after, currentDemand > 0 else {
                    return
                }
                
                totalDemand = currentDemand
            }
        }
        
        // MARK: Subscription
        override func request(_ demand: Subscribers.Demand) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .subscribing(demand)) {
                
                switch demand {
                case .unlimited:
                    self.fastPath()
                case .max(let amount):
                    if amount > 0 {
                        self.slowPath(demand)
                    }
                }
            } else if let demands = self.state.tryAdd(demand), demands.before <= 0 {
                self.slowPath(demands.after)
            }
        }
        
        override func cancel() {
            self.state.store(.finished)
            
            for child in self.children.exchange(with: []) {
                child.subscription.exchange(with: nil)?.cancel()
            }
            self.subscription.exchange(with: nil)?.cancel()
        }
        
        // MARK: ChildSubsciber
        func receive(_ input: P.Output, from child: ChildSubscriber) -> Subscribers.Demand {
            guard self.state.isSubscribing else {
                return .none
            }
            
            self.buffer.withLockMutating {
                $0.append(input)
            }
            self.drain()
            return .max(1)
        }
        
        func receive(completion: Subscribers.Completion<P.Failure>, from child: ChildSubscriber) {
            guard self.state.isSubscribing else {
                return
            }
            
            switch completion {
            case .failure(let error):
                self.sub.receive(completion: .failure(error))
                self.state.store(.finished)
            case .finished:
                self.children.withLockMutating {
                    $0.removeAll(where: { $0 === child })
                }
                self.drain()
                self.subscription.load()?.request(.max(1))
            }
        }
        
        // MARK: Subscriber
        func receive(subscription: Subscription) {
            if Atomic.ifNil(self.subscription, store: subscription) {
                subscription.request(self.pub.maxPublishers)
                self.sub.receive(subscription: self)
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.subscription.load() != nil, self.state.isSubscribing else {
                return .none
            }
            
            let p = self.pub.transform(input)
            let s = ChildSubscriber(parent: self)
            self.children.withLockMutating {
                $0.append(s)
            }
            p.subscribe(s)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<P.Failure>) {
            if let subscription = self.subscription.exchange(with: nil) {
                subscription.cancel()
                
                switch completion {
                case .finished:
                    self.drain()
                case .failure(let error):
                    self.sub.receive(completion: .failure(error))
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
