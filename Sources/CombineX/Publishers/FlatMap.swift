import Foundation

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
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.FlatMap {
    
    final class Inner<S>:
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
        
        // for upstream
        let upstreamState = Atomic<RelaySubscriberState>(value: .waiting)
        
        // for downstream
        let lock = Lock(recursive: true)
        var children: [ChildSubscriber] = []
        var state = SubscriptionState.waiting
        
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
        
        // MARK: Subscription
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            
            switch self.state {
            case .waiting:
                self.state = .subscribing(demand)
                if demand > 0 {
                    self.drain(demand)
                }
            case .subscribing(let before):
                let after = before + demand
                self.state = .subscribing(after)
                
                if before <= 0 && after > 0 {
                    self.drain(after)
                }
            default:
                break
            }
        }
        
        func cancel() {
            self.lock.lock()
            
            self.state = .finished
            
            let children = self.children
            self.children = []
            
            self.lock.unlock()
            
            children.forEach {
                $0.subscription.exchange(with: nil)?.cancel()
            }
            
            self.upstreamState.finishIfSubscribing()?.cancel()
            
            self.pub = nil
            self.sub = nil
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
            
            // Against misbehaving upstream
            guard self.upstreamState.isSubscribing else {
                return .none
            }
            
            guard let pub = self.pub else {
                return .none
            }

            let child = ChildSubscriber(parent: self)
            
            self.lock.lock()
            if self.state.isFinished {
                self.lock.unlock()
                return .none
            }

            self.children.append(child)
            self.lock.unlock()
            
            pub.transform(input).subscribe(child)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<P.Failure>) {
            guard let subscription = self.upstreamState.finishIfSubscribing() else {
                return
            }
            
            subscription.cancel()
            
            self.lock.lock()
            
            switch completion {
            case .finished:
                
                if self.children.isEmpty {

                    guard self.state.isSubscribing else {
                        self.lock.unlock()
                        return
                    }
                    
                    self.state = .finished
                    self.sub?.receive(completion: .finished)
                    self.lock.unlock()
                    
                    self.pub = nil
                    self.sub = nil
                } else {
                    self.lock.unlock()
                }
            case .failure(let error):
                guard self.state.isSubscribing else {
                    self.lock.unlock()
                    return
                }
                
                self.state = .finished
                self.sub?.receive(completion: .failure(error))
                
                let children = self.children
                self.children = []
                
                self.lock.unlock()
                
                children.forEach {
                    $0.subscription.exchange(with: nil)?.cancel()
                }
                
                self.pub = nil
                self.sub = nil
            }
        }
        
        // MARK: ChildSubsciber
        func receive(_ input: P.Output, from child: ChildSubscriber) -> Subscribers.Demand {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            
            guard let before = self.state.demand else {
                return .none
            }

            if before > 0 {
                let new = self.sub?.receive(input) ?? .none
                
                let after = before + new - 1
                self.state = .subscribing(after)
                
                if after > 0 {
                    self.drain(after)
                }
                return .max(1)
            } else {
                child.buffer = input
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<P.Failure>, from child: ChildSubscriber) {
            self.lock.lock()
            
            guard self.state.isSubscribing else {
                self.lock.unlock()
                return
            }
            
            switch completion {
            case .finished:
                self.children.removeAll(where: { $0 === child })
                
                if let subscription = self.upstreamState.subscription {
                    self.lock.unlock()
                    
                    subscription.request(.max(1))
                } else {
                    if self.children.isEmpty {
                        self.state = .finished
                        self.sub?.receive(completion: .finished)
                        let children = self.children
                        self.children = []
                        
                        self.lock.unlock()
                        
                        children.forEach {
                            $0.subscription.exchange(with: nil)?.cancel()
                        }
                        
                        self.pub = nil
                        self.sub = nil
                    } else {
                        self.lock.unlock()
                    }
                }
            case .failure(let error):
                self.state = .finished
                self.sub?.receive(completion: .failure(error))

                let children = self.children
                self.children = []
                
                self.lock.unlock()
                
                children.forEach {
                    $0.subscription.exchange(with: nil)?.cancel()
                }
                
                self.upstreamState.finishIfSubscribing()?.cancel()
                
                self.pub = nil
                self.sub = nil
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
            for child in self.children {
                guard let input = child.buffer else {
                    continue
                }
                child.buffer = nil
                guard self.state.isSubscribing else {
                    return
                }
                _ = self.sub?.receive(input)
            }
        }
        
        private func slowPath(_ demand: Subscribers.Demand) {
            var current = demand
            
            for child in self.children {
                guard current > 0 else {
                    return
                }
                
                guard let input = child.buffer else {
                    continue
                }
                child.buffer = nil
                
                guard let before = self.state.demand else {
                    return
                }
                
                let new = self.sub?.receive(input) ?? .none
                let after = before + new - 1
                self.state = .subscribing(after)

                if after <= 0 {
                    return
                }
                
                if after == .unlimited {
                    self.fastPath()
                    return
                }
                
                current = after
            }
        }
        
        var description: String {
            return "FlatMap"
        }
        
        var debugDescription: String {
            return "FlatMap"
        }
        
        // MARK: - ChildSubscriber
        final class ChildSubscriber: Subscriber {
            
            typealias Input = P.Output
            typealias Failure = P.Failure
            
            let parent: Inner
            
            let subscription = Atomic<Subscription?>(value: nil)
            var buffer: P.Output?
            
            init(parent: Inner) {
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
