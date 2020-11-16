#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Transforms all elements from an upstream publisher into a new publisher
    /// up to a maximum number of publishers you specify.
    ///
    /// Combine‘s ``Publisher/flatMap(maxPublishers:_:)`` operator performs a
    /// similar function to the ``Sequence.flatmap(_:) operator`` in the Swift
    /// standard library, but turns the elements from one kind of publisher into
    /// a new publisher that is sent to subscribers. Use
    /// ``Publisher/flatMap(maxPublishers:_:)`` when you want to create a new
    /// series of events for downstream subscribers based on the received value.
    /// The closure creates the new ``Publisher`` based on the received value.
    /// The new ``Publisher`` can emit more than one event, and successful
    /// completion of the new ``Publisher`` does not complete the overall stream.
    /// Failure of the new ``Publisher`` will fail the overall stream.
    ///
    /// In the example below, a ``PassthroughSubject`` publishes `WeatherStation`
    /// elements. The ``Publisher/flatMap(maxPublishers:_:)`` receives each
    /// element, creates a ``URL`` from it, and produces a new
    /// ``DataTaskPublisher``, which will publish the data loaded from that
    /// ``URL``.
    ///
    ///     public struct WeatherStation {
    ///         public let stationID: String
    ///     }
    ///
    ///     var weatherPublisher = PassthroughSubject<WeatherStation, URLError>()
    ///
    ///     cancellable = weatherPublisher.flatMap { station -> URLSession.DataTaskPublisher in
    ///         let url = URL(string:"https://weatherapi.example.com/stations/\(station.stationID)/observations/latest")!
    ///         return URLSession.shared.dataTaskPublisher(for: url)
    ///     }
    ///     .sink(
    ///         receiveCompletion: { completion in
    ///             // Handle publisher completion (normal or error).
    ///         },
    ///         receiveValue: {
    ///             // Process the received data.
    ///         }
    ///      )
    ///
    ///     weatherPublisher.send(WeatherStation(stationID: "KSFO")) // San Francisco, CA
    ///     weatherPublisher.send(WeatherStation(stationID: "EGLC")) // London, UK
    ///     weatherPublisher.send(WeatherStation(stationID: "ZBBB")) // Beijing, CN
    ///
    /// - Parameters:
    ///   - maxPublishers: Specifies the maximum number of concurrent publisher
    ///   subscriptions, or ``Combine/Subscribers/Demand/unlimited`` if
    ///   unspecified.
    ///   - transform: A closure that takes an element as a parameter and
    ///   returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream
    /// publisher into a publisher of that element’s type.
    public func flatMap<T, P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) -> P
    ) -> Publishers.FlatMap<P, Self> where T == P.Output, P: Publisher, Failure == P.Failure {
        return .init(upstream: self, maxPublishers: maxPublishers, transform: transform)
    }
    
    /// Transforms all elements from an upstream publisher into a new publisher
    /// up to a maximum number of publishers you specify.
    ///
    /// - Parameters:
    ///   - maxPublishers: Specifies the maximum number of concurrent publisher
    ///   subscriptions, or ``Combine/Subscribers/Demand/unlimited`` if
    ///   unspecified.
    ///   - transform: A closure that takes an element as a parameter and
    ///   returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream
    /// publisher into a publisher of that element’s type.
    public func flatMap<P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) -> P
    ) -> Publishers.FlatMap<Publishers.SetFailureType<P, Failure>, Self> where P: Publisher, P.Failure == Never {
        return .init(upstream: self, maxPublishers: maxPublishers) {
            transform($0).setFailureType(to: Failure.self)
        }
    }
}

extension Publisher where Failure == Never {
    
    /// Transforms all elements from an upstream publisher into a new publisher
    /// up to a maximum number of publishers you specify.
    ///
    /// - Parameters:
    ///   - maxPublishers: Specifies the maximum number of concurrent publisher
    ///   subscriptions, or ``Combine/Subscribers/Demand/unlimited`` if
    ///   unspecified.
    ///   - transform: A closure that takes an element as a parameter and
    ///   returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream
    /// publisher into a publisher of that element’s type.
    public func flatMap<P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) -> P
    ) -> Publishers.FlatMap<P, Publishers.SetFailureType<Self, P.Failure>> where P: Publisher {
        return setFailureType(to: P.Failure.self)
            .flatMap(maxPublishers: maxPublishers, transform)
    }
    
    /// Transforms all elements from an upstream publisher into a new publisher
    /// up to a maximum number of publishers you specify.
    ///
    /// - Parameters:
    ///   - maxPublishers: Specifies the maximum number of concurrent publisher
    ///   subscriptions, or ``Combine/Subscribers/Demand/unlimited`` if
    ///   unspecified.
    ///   - transform: A closure that takes an element as a parameter and
    ///   returns a publisher that produces elements of that type.
    /// - Returns: A publisher that transforms elements from an upstream
    /// publisher into a publisher of that element’s type.
    public func flatMap<P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Output) -> P
    ) -> Publishers.FlatMap<P, Self> where P: Publisher, P.Failure == Never {
        return .init(upstream: self, maxPublishers: maxPublishers, transform: transform)
    }
}

extension Publishers {
    
    public struct FlatMap<NewPublisher, Upstream>: Publisher where NewPublisher: Publisher, Upstream: Publisher, NewPublisher.Failure == Upstream.Failure {
        
        public typealias Output = NewPublisher.Output
        
        public typealias Failure = Upstream.Failure
        
        public let upstream: Upstream
        
        public let maxPublishers: Subscribers.Demand
        
        public let transform: (Upstream.Output) -> NewPublisher
        
        public init(upstream: Upstream, maxPublishers: Subscribers.Demand, transform: @escaping (Upstream.Output) -> NewPublisher) {
            self.upstream = upstream
            self.maxPublishers = maxPublishers
            self.transform = transform
        }
        
        public func receive<S: Subscriber>(subscriber: S) where NewPublisher.Output == S.Input, Upstream.Failure == S.Failure {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.FlatMap {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == NewPublisher.Output,
        S.Failure == NewPublisher.Failure {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        typealias Pub = Publishers.FlatMap<NewPublisher, Upstream>
        typealias Sub = S
        typealias Transform = (Upstream.Output) -> NewPublisher
        
        let maxPublishers: Subscribers.Demand
        let transform: Transform
        
        // for upstream
        let upLock = Lock()
        var upState: RelayState = .waiting
        
        // for downstream
        let downLock = Lock()
        let sub: Sub
        var downState: DemandState = .waiting
        var children = LinkedList<Child>()
        
        init(pub: Pub, sub: Sub) {
            self.transform = pub.transform
            self.maxPublishers = pub.maxPublishers
            self.sub = sub
        }
        
        deinit {
            upLock.cleanupLock()
            downLock.cleanupLock()
        }
        
        // MARK: Subscription
        func request(_ demand: Subscribers.Demand) {
            self.downLock.lock()
            switch self.downState {
            case .waiting:
                self.downState = .demanding(demand)
            
                if demand == .unlimited {
                    self.fastPath()
                } else {
                    self.slowPath(demand)
                }
                
            case .demanding(let old):
                let new = old + demand
                self.downState = .demanding(new)
                
                guard old == 0 else {
                    self.downLock.unlock()
                    return
                }
                
                if new == .unlimited {
                    self.fastPath()
                } else {
                    self.slowPath(new)
                }
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
            
            let children = self.children
            self.children = LinkedList()
            self.downLock.unlock()
            
            children.forEach {
                $0.cancel()
            }
            
            self.upLock.withLockGet(self.upState.complete())?.cancel()
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
            guard self.upLock.withLockGet(self.upState.isRelaying) else {
                return .none
            }
            
            let child = Child(parent: self)
            
            self.downLock.lock()
            if self.downState.isCompleted {
                self.downLock.unlock()
                return .none
            }
            
            self.children.append(child)
            self.downLock.unlock()
            
            self.transform(input).subscribe(child)
            return .none
        }
        
        func receive(completion: Subscribers.Completion<NewPublisher.Failure>) {
            guard let subscription = self.upLock.withLockGet(self.upState.complete()) else {
                return
            }
            
            subscription.cancel()
            
            switch completion {
            case .finished:
                self.downLock.lock()
                if self.children.isEmpty {
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
                
                let children = self.children
                self.children = LinkedList()
                self.downLock.unlock()
                
                children.forEach {
                    $0.cancel()
                }
                
                self.sub.receive(completion: .failure(error))
            }
        }
        
        // MARK: ChildSubsciber
        private func receive(_ input: NewPublisher.Output, from child: Child) -> Subscribers.Demand {
            self.downLock.lock()
            guard let old = self.downState.demand, old > 0 else {
                if child.buffer == nil {
                    child.buffer = input
                    
                    _ = self.children.remove(child)
                    self.children.append(child)
                }
                self.downLock.unlock()
                return .none
            }
            
            _ = self.downState.sub(.max(1))
            self.downLock.unlock()
            
            let more = self.sub.receive(input)
            
            self.downLock.lock()
            guard let new = self.downState.add(more)?.new, new > 0 else {
                self.downLock.unlock()
                return .max(1)
            }
            
            if new == .unlimited {
                self.fastPath()
            } else {
                self.slowPath(new)
            }
            
            return .max(1)
        }
        
        private func receive(completion: Subscribers.Completion<NewPublisher.Failure>, from child: Child) {
            self.downLock.lock()
            guard self.downState.isDemanding else {
                self.downLock.unlock()
                return
            }
            
            switch completion {
            case .finished:
                _ = self.children.remove(child)
                
                if let subscription = self.upLock.withLockGet(self.upState.subscription) {
                    self.downLock.unlock()
                    subscription.request(.max(1))
                } else {
                    if self.children.isEmpty {
                        self.downState = .completed
                        
                        let children = self.children
                        self.children = LinkedList()
                        self.downLock.unlock()
                        
                        children.forEach {
                            $0.cancel()
                        }
                        self.sub.receive(completion: .finished)
                    } else {
                        self.downLock.unlock()
                    }
                }
            case .failure(let error):
                self.downState = .completed
                
                let children = self.children
                self.children = LinkedList()
                self.downLock.unlock()
                
                children.forEach {
                    $0.cancel()
                }
                self.sub.receive(completion: .failure(error))
                
                self.upLock.withLockGet(self.upState.complete())?.cancel()
            }
        }
        
        // MARK: Drain
        private func fastPath() {
            // still locking
            
            var consumed: [Child] = []
            
            let outputs = self.children.compactMap { child -> NewPublisher.Output? in
                let output = child.buffer
                child.buffer = nil
                consumed.append(child)
                return output
            }
            
            self.downLock.unlock()
            
            for output in outputs {
                guard self.downLock.withLockGet(self.downState.isDemanding) else {
                    return
                }
                _ = self.sub.receive(output)
            }
            
            consumed.forEach {
                $0.request(.max(1))
            }
        }
        
        private func slowPath(_ demand: Subscribers.Demand) {
            // still locking
            guard demand > 0 else {
                self.downLock.unlock()
                return
            }
            
            var consumed: [Child] = []
            
            for child in self.children {
                guard self.downState.isDemanding else {
                    self.downLock.unlock()
                    return
                }
                
                guard let input = child.buffer else {
                    continue
                }
                child.buffer = nil
                consumed.append(child)
                
                _ = self.downState.sub(.max(1))
                self.downLock.unlock()
                
                let more = self.sub.receive(input)
                
                self.downLock.lock()
                guard let new = self.downState.add(more)?.new, new > 0 else {
                    self.downLock.unlock()
                    consumed.forEach {
                        $0.request(.max(1))
                    }
                    return
                }
            }
            self.downLock.unlock()
            
            consumed.forEach {
                $0.request(.max(1))
            }
        }
        
        var description: String {
            return "FlatMap"
        }
        
        var debugDescription: String {
            return "FlatMap"
        }
        
        final class Child: Subscriber, Equatable {
            
            typealias Input = NewPublisher.Output
            typealias Failure = NewPublisher.Failure
            
            let parent: Inner
            
            let subscription = LockedAtomic<Subscription?>(nil)
            var buffer: Input?
            
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
            
            func receive(_ input: NewPublisher.Output) -> Subscribers.Demand {
                guard self.subscription.load() != nil else {
                    return .none
                }
                return self.parent.receive(input, from: self)
            }
            
            func receive(completion: Subscribers.Completion<NewPublisher.Failure>) {
                guard let subscription = self.subscription.exchange(nil) else {
                    return
                }
                
                subscription.cancel()
                self.parent.receive(completion: completion, from: self)
            }
            
            func cancel() {
                self.subscription.exchange(nil)?.cancel()
            }
            
            func request(_ demand: Subscribers.Demand) {
                self.subscription.load()?.request(demand)
            }
            
            static func == (a: Child, b: Child) -> Bool {
                return a === b
            }
        }
    }
}
