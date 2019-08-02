extension Publisher {

    /// Publishes either the most-recent or first element published by the upstream publisher in the specified time interval.
    ///
    /// - Parameters:
    ///   - interval: The interval at which to find and emit the most recent element, expressed in the time system of the scheduler.
    ///   - scheduler: The scheduler on which to publish elements.
    ///   - latest: A Boolean value that indicates whether to publish the most recent element. If `false`, the publisher emits the first element received during the interval.
    /// - Returns: A publisher that emits either the most-recent or first element received during the specified interval.
    public func throttle<S>(for interval: S.SchedulerTimeType.Stride, scheduler: S, latest: Bool) -> Publishers.Throttle<Self, S> where S : Scheduler {
        return .init(upstream: self, interval: interval, scheduler: scheduler, latest: latest)
    }
}

extension Publishers {

    /// A publisher that publishes either the most-recent or first element published by the upstream publisher in a specified time interval.
    public struct Throttle<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The interval in which to find and emit the most recent element.
        public let interval: Context.SchedulerTimeType.Stride

        /// The scheduler on which to publish elements.
        public let scheduler: Context

        /// A Boolean value indicating whether to publish the most recent element.
        ///
        /// If `false`, the publisher emits the first element received during the interval.
        public let latest: Bool
        
        public init(upstream: Upstream, interval: Context.SchedulerTimeType.Stride, scheduler: Context, latest: Bool) {
            self.upstream = upstream
            self.interval = interval
            self.scheduler = scheduler
            self.latest = latest
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            if self.latest {
                let s = Latest(pub: self, sub: subscriber)
                self.upstream.subscribe(s)
            } else {
                let s = First(pub: self, sub: subscriber)
                self.upstream.subscribe(s)
            }
        }
    }
}

 
extension Publishers.Throttle {
    
    private final class Latest<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Throttle<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock(recursive: true)
        let scheduler: Context
        let interval: Context.SchedulerTimeType.Stride
        let sub: Sub

        var state = RelayState.waiting
        var demand: Subscribers.Demand = .none
        var timeoutTask: Cancellable?
        var latest: Input?
        
        init(pub: Pub, sub: Sub) {
            self.scheduler = pub.scheduler
            self.interval = pub.interval
            self.sub = sub
            
            self.timeoutTask = self.schedule {
                self.sendValueIfPossible()
            }
        }
        
        private func schedule(_ action: @escaping () -> Void) -> Cancellable {
            return self.scheduler.schedule(after: self.scheduler.now.advanced(by: self.interval), interval: self.interval, action)
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            guard let subscription = self.state.subscription else {
                self.lock.unlock()
                return
            }
            self.demand += demand
            self.lock.unlock()
            
            subscription.request(.unlimited)
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
            self.latest = nil
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            self.latest = input
            self.lock.unlock()
            
            return .none
        }
        
        private func sendValueIfPossible() {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return
            }
            guard self.demand > 0 else {
                self.lock.unlock()
                return
            }
            if let latest = self.latest {
                self.latest = nil
                self.demand -= 1
                self.lock.unlock()
                let more = self.sub.receive(latest)

                self.lock.withLock {
                    self.demand += more
                }
            } else {
                self.lock.unlock()
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            self.latest = nil
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Throttle"
        }
        
        var debugDescription: String {
            return "Throttle"
        }
    }
}


extension Publishers.Throttle {
    
    private final class First<S>:
        Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure
    {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.Throttle<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock()
        let scheduler: Context
        let interval: Context.SchedulerTimeType.Stride
        let sub: Sub

        var state = RelayState.waiting
        var demand: Subscribers.Demand = .none
        var timeoutTask: Cancellable?
        var first: Input?
        
        init(pub: Pub, sub: Sub) {
            self.scheduler = pub.scheduler
            self.interval = pub.interval
            self.sub = sub
            
            self.timeoutTask = self.schedule {
                self.sendValueIfPossible()
            }
        }
        
        private func schedule(_ action: @escaping () -> Void) -> Cancellable {
            return self.scheduler.schedule(after: self.scheduler.now.advanced(by: self.interval), interval: self.interval, action)
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            guard let subscription = self.state.subscription else {
                self.lock.unlock()
                return
            }
            self.demand += demand
            self.lock.unlock()
            
            subscription.request(.unlimited)
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
            self.first = nil
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
        }
        
        func receive(subscription: Subscription) {
            guard self.lock.withLockGet(self.state.relay(subscription)) else {
                subscription.cancel()
                return
            }
            self.sub.receive(subscription: self)
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return .none
            }
            if self.first == nil {
                self.first = input
            }
            self.lock.unlock()
            
            return .none
        }
        
        private func sendValueIfPossible() {
            self.lock.lock()
            guard self.state.isRelaying else {
                self.lock.unlock()
                return
            }
            guard self.demand > 0 else {
                self.lock.unlock()
                return
            }
            if let first = self.first {
                self.first = nil
                self.demand -= 1
                self.lock.unlock()
                let more = self.sub.receive(first)
                
                self.lock.withLock {
                    self.demand += more
                }
            } else {
                self.lock.unlock()
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            self.first = nil
            self.timeoutTask?.cancel()
            self.timeoutTask = nil
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Throttle"
        }
        
        var debugDescription: String {
            return "Throttle"
        }
    }
}
