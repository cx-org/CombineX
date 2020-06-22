#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Measures and emits the time interval between events received from an upstream publisher.
    ///
    /// The output type of the returned scheduler is the time interval of the provided scheduler.
    /// - Parameters:
    ///   - scheduler: The scheduler on which to deliver elements.
    ///   - options: Options that customize the delivery of elements.
    /// - Returns: A publisher that emits elements representing the time interval between the elements it receives.
    public func measureInterval<S: Scheduler>(using scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.MeasureInterval<Self, S> {
        return .init(upstream: self, scheduler: scheduler, options: options)
    }
}

extension Publishers {
    
    /// A publisher that measures and emits the time interval between events received from an upstream publisher.
    public struct MeasureInterval<Upstream: Publisher, Context: Scheduler>: Publisher {
        
        public typealias Output = Context.SchedulerTimeType.Stride
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The scheduler on which to deliver elements.
        public let scheduler: Context
        
        private let options: Context.SchedulerOptions?
        
        init(upstream: Upstream, scheduler: Context, options: Context.SchedulerOptions?) {
            self.upstream = upstream
            self.scheduler = scheduler
            self.options = options
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, S.Input == Context.SchedulerTimeType.Stride {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.MeasureInterval {
    
    private final class Inner<S>: Subscription,
        Subscriber,
        CustomStringConvertible,
        CustomDebugStringConvertible
    where
        S: Subscriber,
        S.Input == Output,
        S.Failure == Failure {
        
        typealias Input = Upstream.Output
        typealias Failure = Upstream.Failure
        
        typealias Pub = Publishers.MeasureInterval<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock()
        
        let sub: Sub
        let scheduler: Context
        let options: Context.SchedulerOptions?
        
        var timestamp: Context.SchedulerTimeType
        var state: RelayState = .waiting
        
        init(pub: Pub, sub: Sub) {
            self.sub = sub
            
            self.scheduler = pub.scheduler
            self.options = pub.options
            self.timestamp = pub.scheduler.now
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.withLockGet(self.state.subscription)?.request(demand)
        }
        
        func cancel() {
            self.lock.withLockGet(self.state.complete())?.cancel()
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
            
            let now = self.scheduler.now
            let interval = self.timestamp.distance(to: now)
            self.timestamp = now
            self.lock.unlock()
            
            return sub.receive(interval)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            
            subscription.cancel()
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "MeasureInterval"
        }
        
        var debugDescription: String {
            return "MeasureInterval"
        }
    }
}
