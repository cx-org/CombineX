extension Publisher {

    /// Collects elements by a given strategy, and emits a single array of the collection.
    ///
    /// If the upstream publisher finishes before filling the buffer, this publisher sends an array of all the items it has received. This may be fewer than `count` elements.
    /// If the upstream publisher fails with an error, this publisher forwards the error to the downstream receiver instead of sending its output.
    /// Note: When this publisher receives a request for `.max(n)` elements, it requests `.max(count * n)` from the upstream publisher.
    /// - Parameters:
    ///   - strategy: The strategy with which to collect and publish elements.
    ///   - options: `Scheduler` options to use for the strategy.
    /// - Returns: A publisher that collects elements by a given strategy, and emits a single array of the collection.
    public func collect<S>(_ strategy: Publishers.TimeGroupingStrategy<S>, options: S.SchedulerOptions? = nil) -> Publishers.CollectByTime<Self, S> where S : Scheduler {
        return .init(upstream: self, strategy: strategy, options: options)
    }
}

extension Publishers {

    /// A strategy for collecting received elements.
    ///
    /// - byTime: Collect and periodically publish items.
    /// - byTimeOrCount: Collect and publish items, either periodically or when a buffer reaches its maximum size.
    public enum TimeGroupingStrategy<Context> where Context : Scheduler {

        case byTime(Context, Context.SchedulerTimeType.Stride)

        case byTimeOrCount(Context, Context.SchedulerTimeType.Stride, Int)
    }

    /// A publisher that buffers and periodically publishes its items.
    public struct CollectByTime<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = [Upstream.Output]

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The strategy with which to collect and publish elements.
        public let strategy: Publishers.TimeGroupingStrategy<Context>

        /// `Scheduler` options to use for the strategy.
        public let options: Context.SchedulerOptions?
        
        public init(upstream: Upstream, strategy: Publishers.TimeGroupingStrategy<Context>, options: Context.SchedulerOptions?) {
            self.upstream = upstream
            self.strategy = strategy
            self.options = options
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, S.Input == [Upstream.Output] {
            switch self.strategy {
            case .byTime:
                let s = ByTime(pub: self, sub: subscriber)
                self.upstream.subscribe(s)
            case .byTimeOrCount:
                let s = ByTimeOrCount(pub: self, sub: subscriber)
                self.upstream.subscribe(s)
            }
        }
    }
}


// MARK: - ByTimeOrCount
extension Publishers.CollectByTime {
    
    private final class ByTimeOrCount<S>:
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
        
        typealias Pub = Publishers.CollectByTime<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock(recursive: true)
        let strategy: Publishers.TimeGroupingStrategy<Context>
        let sub: Sub
        
        let context: Context
        let time: Context.SchedulerTimeType.Stride
        let count: Int
        
        var state = RelayState.waiting
        var buffer: [Input] = []
        var timeoutTask: Cancellable?
        
        init(pub: Pub, sub: Sub) {
            self.strategy = pub.strategy
            self.sub = sub
        
            guard case .byTimeOrCount(let context, let time, let count) = pub.strategy else {
                Global.Never()
            }
            self.context = context
            self.time = time
            self.count = count
            
            self.buffer.reserveCapacity(self.count)
            self.rescheduleTimeoutTask()
        }
        
        func rescheduleTimeoutTask() {
            self.lock.lock()
            self.timeoutTask?.cancel()
            self.timeoutTask = self.context.schedule(
                after: self.context.now.advanced(by: self.time),
                interval: .seconds(Int.max))
            {
                self.lock.lock()
                guard self.state.isRelaying else {
                    self.lock.unlock()
                    return
                }
                
                let buffer = self.buffer
                self.buffer.removeAll(keepingCapacity: true)
                self.lock.unlock()
                
                self.rescheduleTimeoutTask()
                
                if buffer.isEmpty {
                    return
                }
                
                _ = self.sub.receive(buffer)
            }
            self.lock.unlock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.withLockGet(self.state.subscription)?.request(demand * self.count)
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
            
            self.buffer.append(input)
            
            switch self.buffer.count {
            case self.count:
                let output = self.buffer
                self.buffer.removeAll(keepingCapacity: true)
                self.lock.unlock()
                self.rescheduleTimeoutTask()
                return self.sub.receive(output) * self.count
            default:
                self.lock.unlock()
                return .max(0)
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            guard let subscription = self.state.complete() else {
                self.lock.unlock()
                return
            }
            
            let task = self.timeoutTask
            self.timeoutTask = nil
            self.lock.unlock()
            
            subscription.cancel()
            task?.cancel()
            
            switch completion {
            case .finished:
                let output = self.buffer
                self.buffer = []
                if !output.isEmpty {
                    _ = self.sub.receive(output)
                }
                self.sub.receive(completion: completion)
            case .failure:
                self.buffer = []
                self.sub.receive(completion: completion)
            }
        }
        
        var description: String {
            return "CollectByTime"
        }
        
        var debugDescription: String {
            return "CollectByTime"
        }
    }
}


// MARK: - ByTime
extension Publishers.CollectByTime {
    
    private final class ByTime<S>:
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
        
        typealias Pub = Publishers.CollectByTime<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock(recursive: true)
        let sub: Sub
        
        let context: Context
        let time: Context.SchedulerTimeType.Stride
        
        var state = RelayState.waiting
        var demand: Subscribers.Demand = .none
        var buffer: [Input] = []
        var timeoutTask: Cancellable?
        
        init(pub: Pub, sub: Sub) {
            self.sub = sub
        
            guard case .byTime(let context, let time) = pub.strategy else {
                Global.Never()
            }
            self.context = context
            self.time = time
            
            self.rescheduleTimeoutTask()
        }
        
        func rescheduleTimeoutTask() {
            self.lock.lock()
            self.timeoutTask?.cancel()
            self.timeoutTask = self.context.schedule(
                after: self.context.now.advanced(by: self.time),
                interval: .seconds(Int.max))
            {
                self.lock.lock()
                guard self.state.isRelaying else {
                    self.lock.unlock()
                    return
                }
                
                defer {
                    self.rescheduleTimeoutTask()
                }
                
                guard self.demand > 0 else {
                    self.lock.unlock()
                    return
                }
                
                let buffer = self.buffer
                self.buffer.removeAll(keepingCapacity: true)
                
                if buffer.isEmpty {
                    self.lock.unlock()
                    return
                }
                self.demand -= 1
                self.lock.unlock()
                
                let more = self.sub.receive(buffer)
                
                if more > 0 {
                    self.lock.withLock {
                        self.demand += more
                    }
                }
            }
            self.lock.unlock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            guard let subscription = self.state.subscription else {
                self.lock.unlock()
                return
            }
            self.demand += demand
            self.lock.unlock()
            
            subscription.request(.max(1))
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
            
            self.buffer.append(input)
            self.lock.unlock()
            
            return .max(1)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            guard let subscription = self.state.complete() else {
                self.lock.unlock()
                return
            }
            
            let task = self.timeoutTask
            self.timeoutTask = nil
            self.lock.unlock()
            
            subscription.cancel()
            task?.cancel()
            
            switch completion {
            case .finished:
                let output = self.buffer
                self.buffer = []
                if !output.isEmpty {
                    _ = self.sub.receive(output)
                }
                self.sub.receive(completion: completion)
            case .failure:
                self.buffer = []
                self.sub.receive(completion: completion)
            }
        }
        
        var description: String {
            return "CollectByTime"
        }
        
        var debugDescription: String {
            return "CollectByTime"
        }
    }
}

