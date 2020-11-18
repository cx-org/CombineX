#if !COCOAPODS
import CXUtility
#endif

extension Publisher where Failure == Output.Failure, Output: Publisher {
    
    /// Republishes elements sent by the most recently received publisher.
    ///
    /// This operator works with an upstream publisher of publishers, flattening
    /// the stream of elements to appear as if they were coming from a single
    /// stream of elements. It switches the inner publisher as new ones arrive
    /// but keeps the outer publisher constant for downstream subscribers.
    ///
    /// For example, given the type
    /// `AnyPublisher<URLSession.DataTaskPublisher, NSError>`, calling
    /// `switchToLatest()` results in the type
    /// `SwitchToLatest<(Data, URLResponse), URLError>`. The downstream
    /// subscriber sees a continuous stream of `(Data, URLResponse)` elements
    /// from what looks like a single `DataTaskPublisher` even though the
    /// elements are coming from different upstream publishers.
    ///
    /// When this operator receives a new publisher from the upstream publisher,
    /// it cancels its previous subscription. Use this feature to prevent
    /// earlier publishers from performing unnecessary work, such as creating
    /// network request publishers from frequently updating user interface
    /// publishers.
    ///
    /// The following example updates a ``PassthroughSubject`` with a new value
    /// every `0.1` seconds. A ``Publisher/map(_:)-99evh`` operator receives the
    /// new value and uses it to create a new `DataTaskPublisher`. By using the
    /// `switchToLatest()` operator, the downstream sink subscriber receives the
    /// `(Data, URLResponse)` output type from the data task publishers, rather
    /// than the `DataTaskPublisher` type produced by the ``Publisher.map(_:)``
    /// operator. Furthermore, creating each new data task publisher cancels the
    /// previous data task publisher.
    ///
    ///     let subject = PassthroughSubject<Int, Never>()
    ///     cancellable = subject
    ///         .setFailureType(to: URLError.self)
    ///         .map() { index -> URLSession.DataTaskPublisher in
    ///             let url = URL(string: "https://example.org/get?index=\(index)")!
    ///             return URLSession.shared.dataTaskPublisher(for: url)
    ///         }
    ///         .switchToLatest()
    ///         .sink(receiveCompletion: { print("Complete: \($0)") },
    ///               receiveValue: { (data, response) in
    ///                 guard let url = response.url else { print("Bad response."); return }
    ///                 print("URL: \(url)")
    ///         })
    ///
    ///     for index in 1...5 {
    ///         DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(index/10)) {
    ///             subject.send(index)
    ///         }
    ///     }
    ///
    ///     // Prints "URL: https://example.org/get?index=5"
    ///
    /// The exact behavior of this example depends on the value of `asyncAfter`
    /// and the speed of the network connection. If the delay value is longer,
    /// or the network connection is fast, the earlier data tasks may complete
    /// before `switchToLatest()` can cancel them. If this happens, the output
    /// includes multiple URLs whose tasks complete before cancellation.
    public func switchToLatest() -> Publishers.SwitchToLatest<Output, Self> {
        return .init(upstream: self)
    }
}

extension Publisher where Output: Publisher, Output.Failure == Never {

    /// Republishes elements sent by the most recently received publisher.
    ///
    /// This operator works with an upstream publisher of publishers, flattening
    /// the stream of elements to appear as if they were coming from a single
    /// stream of elements. It switches the inner publisher as new ones arrive
    /// but keeps the outer publisher constant for downstream subscribers.
    ///
    /// When this operator receives a new publisher from the upstream publisher,
    /// it cancels its previous subscription. Use this feature to prevent
    /// earlier publishers from performing unnecessary work, such as creating
    /// network request publishers from frequently updating user interface
    /// publishers.
    public func switchToLatest() -> Publishers.SwitchToLatest<Publishers.SetFailureType<Output, Failure>, Publishers.Map<Self, Publishers.SetFailureType<Output, Failure>>> {
        return map { $0.setFailureType(to: Failure.self) }
            .switchToLatest()
    }
}

extension Publisher where Failure == Never, Output: Publisher {

    /// Republishes elements sent by the most recently received publisher.
    ///
    /// This operator works with an upstream publisher of publishers, flattening
    /// the stream of elements to appear as if they were coming from a single
    /// stream of elements. It switches the inner publisher as new ones arrive
    /// but keeps the outer publisher constant for downstream subscribers.
    ///
    /// When this operator receives a new publisher from the upstream publisher,
    /// it cancels its previous subscription. Use this feature to prevent
    /// earlier publishers from performing unnecessary work, such as creating
    /// network request publishers from frequently updating user interface
    /// publishers.
    public func switchToLatest() -> Publishers.SwitchToLatest<Output, Publishers.SetFailureType<Self, Output.Failure>> {
        return setFailureType(to: Output.Failure.self)
            .switchToLatest()
    }
}

extension Publisher where Failure == Never, Output: Publisher, Output.Failure == Never {

    /// Republishes elements sent by the most recently received publisher.
    ///
    /// This operator works with an upstream publisher of publishers, flattening the stream of elements to appear as if they were coming from a single stream of elements. It switches the inner publisher as new ones arrive but keeps the outer publisher constant for downstream subscribers.
    ///
    /// When this operator receives a new publisher from the upstream publisher, it cancels its previous subscription. Use this feature to prevent earlier publishers from performing unnecessary work, such as creating network request publishers from frequently updating user interface publishers.
    public func switchToLatest() -> Publishers.SwitchToLatest<Output, Self> {
        return .init(upstream: self)
    }
}

extension Publishers {
    
    /// A publisher that “flattens” nested publishers.
    ///
    /// Given a publisher that publishes Publishers, the `SwitchToLatest` publisher produces a
    /// sequence of events from only the most recent one.
    ///
    /// For example, given the type `Publisher<Publisher<Data, NSError>, Never>`, calling
    /// `switchToLatest()` will result in the type `Publisher<Data, NSError>`. The
    /// downstream subscriber sees a continuous stream of values even though they may be coming from
    /// different upstream publishers.
    public struct SwitchToLatest<P: Publisher, Upstream>: Publisher where P == Upstream.Output, Upstream: Publisher, P.Failure == Upstream.Failure {
        
        public typealias Output = P.Output
        
        public typealias Failure = P.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// Creates a publisher that “flattens” nested publishers.
        ///
        /// - Parameter upstream: The publisher from which this publisher receives elements.
        public init(upstream: Upstream) {
            self.upstream = upstream
        }
        
        public func receive<S: Subscriber>(subscriber: S) where P.Output == S.Input, Upstream.Failure == S.Failure {
            let s = Inner(sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.SwitchToLatest {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == P.Output,
        S.Failure == P.Failure {
        
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
            
            let subscription = LockedAtomic<Subscription?>(nil)
            
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
                guard self.subscription.load() != nil else {
                    return .none
                }
                return self.parent.receive(input, from: self)
            }
            
            func receive(completion: Subscribers.Completion<P.Failure>) {
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
        }
    }
}
