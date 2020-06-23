#if !COCOAPODS
import CXUtility
#endif

extension Publisher {

    /// Delays delivery of all output to the downstream receiver by a specified amount of time on a particular scheduler.
    ///
    /// The delay affects the delivery of elements and completion, but not of the original subscription.
    /// - Parameters:
    ///   - interval: The amount of time to delay.
    ///   - tolerance: The allowed tolerance in firing delayed events.
    ///   - scheduler: The scheduler to deliver the delayed events.
    /// - Returns: A publisher that delays delivery of elements and completion to the downstream receiver.
    public func delay<S: Scheduler>(for interval: S.SchedulerTimeType.Stride, tolerance: S.SchedulerTimeType.Stride? = nil, scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.Delay<Self, S> {
        return .init(upstream: self, interval: interval, tolerance: tolerance ?? scheduler.minimumTolerance, scheduler: scheduler, options: options)
    }
}

extension Publishers {

    /// A publisher that delays delivery of elements and completion to the downstream receiver.
    public struct Delay<Upstream: Publisher, Context: Scheduler>: Publisher {

        public typealias Output = Upstream.Output

        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The amount of time to delay.
        public let interval: Context.SchedulerTimeType.Stride

        /// The allowed tolerance in firing delayed events.
        public let tolerance: Context.SchedulerTimeType.Stride

        /// The scheduler to deliver the delayed events.
        public let scheduler: Context
        
        public let options: Context.SchedulerOptions?
        
        public init(upstream: Upstream, interval: Context.SchedulerTimeType.Stride, tolerance: Context.SchedulerTimeType.Stride, scheduler: Context, options: Context.SchedulerOptions? = nil) {
            self.upstream = upstream
            self.interval = interval
            self.tolerance = tolerance
            self.scheduler = scheduler
            self.options = options
        }

        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.Delay {
    
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
        
        typealias Pub = Publishers.Delay<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock()
        let interval: Context.SchedulerTimeType.Stride
        let tolerance: Context.SchedulerTimeType.Stride
        let scheduler: Context
        let options: Context.SchedulerOptions?
        let sub: Sub
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.interval = pub.interval
            self.tolerance = pub.tolerance
            self.scheduler = pub.scheduler
            self.options = pub.options
            self.sub = sub
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
        
        private func delay(_ action: @escaping () -> Void) {
            self.scheduler.schedule(
                after: self.scheduler.now.advanced(by: self.interval),
                tolerance: self.tolerance,
                options: self.options) {
                action()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            guard self.lock.withLockGet(self.state.isRelaying) else {
                return .none
            }
            
            self.delay {
                let more = self.sub.receive(input)
                guard more > 0, let subscription = self.lock.withLockGet(self.state.subscription) else {
                    return
                }
                subscription.request(more)
            }
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            
            self.delay {
                self.sub.receive(completion: completion)
            }
        }
        
        var description: String {
            return "Delay"
        }
        
        var debugDescription: String {
            return "Delay"
        }
    }
}
