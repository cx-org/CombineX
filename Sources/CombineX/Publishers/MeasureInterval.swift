extension Publisher {
    
    /// Measures and emits the time interval between events received from an upstream publisher.
    ///
    /// The output type of the returned scheduler is the time interval of the provided scheduler.
    /// - Parameters:
    ///   - scheduler: The scheduler on which to deliver elements.
    ///   - options: Options that customize the delivery of elements.
    /// - Returns: A publisher that emits elements representing the time interval between the elements it receives.
    public func measureInterval<S>(using scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.MeasureInterval<Self, S> where S : Scheduler {
        return .init(upstream: self, scheduler: scheduler, options: options)
    }
}

extension Publishers {
    
    /// A publisher that measures and emits the time interval between events received from an upstream publisher.
    public struct MeasureInterval<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {
        
        /// The kind of values published by this publisher.
        public typealias Output = Context.SchedulerTimeType.Stride
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
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
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == Context.SchedulerTimeType.Stride {
            let subscription = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(subscription)
        }
    }
}

extension Publishers.MeasureInterval {
    
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
        
        typealias Pub = Publishers.MeasureInterval<Upstream, Context>
        typealias Sub = S
        
        let state = Atomic<RelayState>(value: .waiting)
        
        var pub: Pub?
        var sub: Sub?
        
        var timestamp: Context.SchedulerTimeType
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
            
            self.timestamp = pub.scheduler.now
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.state.subscription?.request(demand)
        }
        
        func cancel() {
            self.state.finishIfRelaying()?.cancel()
            
            self.pub = nil
            self.sub = nil
        }
        
        func receive(subscription: Subscription) {
            if self.state.compareAndStore(expected: .waiting, newVaue: .relaying(subscription)) {
                self.sub?.receive(subscription: self)
            } else {
                subscription.cancel()
            }
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            let internval = self.state.withLock { state -> Context.SchedulerTimeType.Stride? in
                guard state.isRelaying else {
                    return nil
                }
                
                guard let pub = self.pub else {
                    return nil
                }
                
                let now = pub.scheduler.now
                let interval = now.distance(to: self.timestamp)
                self.timestamp = now
                return interval
            }
            
            if let interval = internval, let sub = self.sub {
                return sub.receive(interval)
            } else {
                return .none
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            if let subscription = self.state.finishIfRelaying() {
                subscription.cancel()
                self.sub?.receive(completion: completion)
                self.pub = nil
                self.sub = nil
            }
        }
        
        var description: String {
            return "MeasureInterval"
        }
        
        var debugDescription: String {
            return "MeasureInterval"
        }
    }
}

