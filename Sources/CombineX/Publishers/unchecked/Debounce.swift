extension Publisher {

    /// Publishes elements only after a specified time interval elapses between events.
    ///
    /// Use this operator when you want to wait for a pause in the delivery of events from the upstream publisher. For example, call `debounce` on the publisher from a text field to only receive elements when the user pauses or stops typing. When they start typing again, the `debounce` holds event delivery until the next pause.
    /// - Parameters:
    ///   - dueTime: The time the publisher should wait before publishing an element.
    ///   - scheduler: The scheduler on which this publisher delivers elements
    ///   - options: Scheduler options that customize this publisher’s delivery of elements.
    /// - Returns: A publisher that publishes events only after a specified time elapses.
    public func debounce<S>(for dueTime: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.Debounce<Self, S> where S : Scheduler {
        return .init(upstream: self, dueTime: dueTime, scheduler: scheduler, options: options)
    }
}


extension Publishers {

    /// A publisher that publishes elements only after a specified time interval elapses between events.
    public struct Debounce<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream

        /// The amount of time the publisher should wait before publishing an element.
        public let dueTime: Context.SchedulerTimeType.Stride

        /// The scheduler on which this publisher delivers elements.
        public let scheduler: Context

        /// Scheduler options that customize this publisher’s delivery of elements.
        public let options: Context.SchedulerOptions?
        
        public init(upstream: Upstream, dueTime: Context.SchedulerTimeType.Stride, scheduler: Context, options: Context.SchedulerOptions?) {
            self.upstream = upstream
            self.dueTime = dueTime
            self.scheduler = scheduler
            self.options = options
        }


        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
//            let s = Inner(pub: self, sub: subscriber)
//            self.upstream.subscribe(s)
        }
    }
}

/*
 

extension Publishers.Debounce {
    
    private final class Inner<S>:
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
        
        typealias Pub = Publishers.Debounce<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock()
        let scheduler: Context
        let dueTime: Context.SchedulerTimeType.Stride
        let options: Context.SchedulerOptions?
        let sub: Sub

        var state = RelayState.waiting
        var lastSending: Context.SchedulerTimeType
        
        init(pub: Pub, sub: Sub) {
            self.scheduler = pub.scheduler
            self.dueTime = pub.dueTime
            self.options = pub.options
            self.sub = sub
            self.lastSending = pub.scheduler.now.advanced(by: -pub.dueTime)
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
            
            if self.lastSending.distance(to: self.scheduler.now) < self.dueTime {
                self.lock.unlock()
                return .max(1)
            }
            self.lock.unlock()
            
            let more = self.sub.receive(input)
            
            self.lock.lock()
            self.lastSending = self.scheduler.now
            self.lock.unlock()
            
            return more
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Debounce"
        }
        
        var debugDescription: String {
            return "Debounce"
        }
    }
}
 */
