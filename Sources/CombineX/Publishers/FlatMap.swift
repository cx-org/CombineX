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
        return .init(upstream: self, maxPublishers: maxPublishers, transform: transform)
    }
}

extension Publishers {
    
    public struct FlatMap<NewPublisher, Upstream> : Publisher where NewPublisher : Publisher, Upstream : Publisher, NewPublisher.Failure == Upstream.Failure {
        
        /// The kind of values published by this publisher.
        public typealias Output = NewPublisher.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let maxPublishers: Subscribers.Demand
        
        public let transform: (Upstream.Output) -> NewPublisher
        
        public init(upstream: Upstream, maxPublishers: Subscribers.Demand, transform: @escaping (Upstream.Output) -> NewPublisher) {
            self.upstream = upstream
            self.maxPublishers = maxPublishers
            self.transform = transform
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, NewPublisher.Output == S.Input, Upstream.Failure == S.Failure {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.FlatMap {
    
    private final class Inner<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == NewPublisher.Output,
        S.Failure == NewPublisher.Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        typealias Transform = (Upstream.Output) -> NewPublisher
        typealias Pub = Publishers.FlatMap<NewPublisher, Upstream>
        typealias Sub = S
        
        // for upstream
        let upLock = Lock()
        var upState: RelayState = .waiting
        
        // for downstream
        let downLock = Lock()
        var downState: SubscriptionState = .waiting
        var children: [ChildSubscriber] = []
        var sub: Sub
        
        let maxPublishers: Subscribers.Demand
        let transform: Transform
        
        init(pub: Pub, sub: Sub) {
            self.transform = pub.transform
            self.maxPublishers = pub.maxPublishers
            self.sub = sub
        }
        
        // MARK: Subscription
        func request(_ demand: Subscribers.Demand) {
            self.downLock.lock()
            switch self.downState {
            case .waiting:
                self.downState = .subscribing(demand)
                self.downLock.unlock()
                
                if demand > 0 {
                    self.drain(demand)
                }
            case .subscribing(let before):
                let after = before + demand
                self.downState = .subscribing(after)
                self.downLock.unlock()
                
                if before == 0 && after > 0 {
                    self.drain(after)
                }
            default:
                self.downLock.unlock()
            }
        }
        
        func cancel() {
            self.downLock.lock()
            self.downState = .finished
            let children = self.children
            self.children = []
            self.downLock.unlock()
            
            children.forEach {
                $0.subscription.exchange(with: nil)?.cancel()
            }
            
            self.upLock.withLockGet(self.upState.finish())?.cancel()
        }
        
        // MARK: Subscriber
        func receive(subscription: Subscription) {
            guard self.upLock.withLockGet(self.upState.relay(subscription)) else {
                subscription.cancel()
                return
            }
            self.sub.receive(subscription: self)
            subscription.request(self.maxPublishers)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            // Against misbehaving upstream
            guard self.upLock.withLockGet(self.upState.isRelaying) else {
                return .none
            }
            
            let child = ChildSubscriber(parent: self)
            
            self.downLock.lock()
            guard self.downState.isSubscribing else {
                self.downLock.unlock()
                return .none
            }
            
            self.children.append(child)
            self.downLock.unlock()
            
            self.transform(input).subscribe(child)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<NewPublisher.Failure>) {
            guard let subscription = self.upLock.withLockGet(self.upState.subscription) else {
                return
            }
            
            subscription.cancel()
            
            switch completion {
            case .finished:
                self.downLock.lock()
                if self.children.isEmpty {
                    guard self.downState.isSubscribing else {
                        self.downLock.unlock()
                        return
                    }
                    self.downState = .finished
                    self.downLock.unlock()
                    self.sub.receive(completion: .finished)
                } else {
                    self.downLock.unlock()
                }
            case .failure(let error):
                self.downLock.lock()
                guard self.downState.isSubscribing else {
                    self.downLock.unlock()
                    return
                }
                
                self.downState = .finished
                let children = self.children
                self.children = []
                self.downLock.unlock()
                
                children.forEach {
                    $0.subscription.exchange(with: nil)?.cancel()
                }
                
                self.sub.receive(completion: .failure(error))
            }
        }
        
        // MARK: ChildSubsciber
        func receive(_ input: NewPublisher.Output, from child: ChildSubscriber) -> Subscribers.Demand {
            self.downLock.lock()
            guard let before = self.downState.demand else {
                self.downLock.unlock()
                return .none
            }
            
            if before > 0 {
                self.downState = .subscribing(before - 1)
                self.downLock.unlock()
                
                let new = self.sub.receive(input)
                
                self.downLock.lock()
                var after = Subscribers.Demand.max(0)
                if let demand = self.downState.demand {
                    after = demand + new
                    self.downState = .subscribing(after)
                }
                self.downLock.unlock()
                
                if after > 0 {
                    self.drain(after)
                }
                return .max(1)
            } else {
                if child.buffer == nil {
                    child.buffer = input
                    self.children.removeAll(where: { $0 === child })
                    self.children.append(child)
                }
                self.downLock.unlock()
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<NewPublisher.Failure>, from child: ChildSubscriber) {
            self.downLock.lock()
            guard self.downState.isSubscribing else {
                self.downLock.unlock()
                return
            }
            
            switch completion {
            case .finished:
                self.children.removeAll(where: { $0 === child })
                
                if let subscription = self.upLock.withLockGet(self.upState.subscription) {
                    self.downLock.unlock()
                    subscription.request(.max(1))
                } else {
                    if self.children.isEmpty {
                        self.downState = .finished
                        let children = self.children
                        self.children = []
                        self.downLock.unlock()
                        
                        children.forEach {
                            $0.subscription.exchange(with: nil)?.cancel()
                        }
                        self.sub.receive(completion: .finished)
                    } else {
                        self.downLock.unlock()
                    }
                }
            case .failure(let error):
                self.downState = .finished
                
                let children = self.children
                self.children = []
                self.downLock.unlock()
                
                children.forEach {
                    $0.subscription.exchange(with: nil)?.cancel()
                }
                self.sub.receive(completion: .failure(error))
                
                self.upLock.withLockGet(self.upState.finish())?.cancel()
            }
        }
        
        // MARK: Drain
        func drain(_ demand: Subscribers.Demand) {
            if demand == .unlimited {
                self.fastPath()
            } else {
                self.slowPath(demand)
            }
        }
        
        private func fastPath() {
            let buffer = self.downLock.withLock {
                self.children.compactMap { child -> NewPublisher.Output? in
                    let buffer = child.buffer
                    child.buffer = nil
                    return buffer
                }
            }
            
            for output in buffer {
                guard self.downLock.withLockGet(self.downState.isSubscribing) else {
                    return
                }
                _ = self.sub.receive(output)
            }
        }
        
        private func slowPath(_ demand: Subscribers.Demand) {
            var current = demand

            self.downLock.lock()
            for child in self.children {
                guard current > 0 else {
                    self.downLock.unlock()
                    return
                }

                guard let input = child.buffer else {
                    continue
                }
                child.buffer = nil

                guard let before = self.downState.demand else {
                    self.downLock.unlock()
                    return
                }
                self.downState = .subscribing(before - 1)
                self.downLock.unlock()

                let new = self.sub.receive(input)

                self.downLock.lock()
                var after = Subscribers.Demand.max(0)
                if let demand = self.downState.demand {
                    after = demand + new
                    self.downState = .subscribing(after)
                }

                if after == 0 {
                    self.downLock.unlock()
                    return
                }

                current = after
            }
            self.downLock.unlock()
        }
        
        var description: String {
            return "FlatMap"
        }
        
        var debugDescription: String {
            return "FlatMap"
        }
        
        // MARK: - ChildSubscriber
        final class ChildSubscriber: Subscriber {
            
            typealias Input = NewPublisher.Output
            typealias Failure = NewPublisher.Failure
            
            let parent: Inner
            
            let subscription = Atom<Subscription?>(nil)
            var buffer: Input?
            
            init(parent: Inner) {
                self.parent = parent
            }
            
            func receive(subscription: Subscription) {
                if self.subscription.ifNilStore(subscription) {
                    subscription.request(.max(1))
                } else {
                    subscription.cancel()
                }
            }
            
            func receive(_ input: NewPublisher.Output) -> Subscribers.Demand {
                guard self.subscription.isNotNil else {
                    return .none
                }
                return self.parent.receive(input, from: self)
            }
            
            func receive(completion: Subscribers.Completion<NewPublisher.Failure>) {
                guard let subscription = self.subscription.exchange(with: nil) else {
                    return
                }
                
                subscription.cancel()
                self.parent.receive(completion: completion, from: self)
            }
        }
    }
}
