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
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.CollectByTime {
    
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
        
        typealias Pub = Publishers.CollectByTime<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock(recursive: true)
        let strategy: Publishers.TimeGroupingStrategy<Context>
        let sub: Sub
        
        var context: Context {
            switch self.strategy {
            case .byTime(let s, _):             return s
            case .byTimeOrCount(let s, _, _):   return s
            }
        }
        
        var time: Context.SchedulerTimeType.Stride {
            switch self.strategy {
            case .byTime(_, let t):             return t
            case .byTimeOrCount(_, let t, _):   return t
            }
        }
        
        var count: Int? {
            switch self.strategy {
            case .byTime:                       return nil
            case .byTimeOrCount(_, _, let c):   return c
            }
        }
        
        var state = RelayState.waiting
        var buffer: [Input] = []
        var timeoutCancellable: Cancellable?
        
        init(pub: Pub, sub: Sub) {
            self.strategy = pub.strategy
            self.sub = sub
        
            if case .byTimeOrCount(_, _, let count) = self.strategy {
                self.buffer.reserveCapacity(count)
            }
        }
        
        func rescheduleTimeout() {
            self.lock.lock()
            self.timeoutCancellable?.cancel()
            self.timeoutCancellable = self.context.schedule(
                after: self.context.now.advanced(by: self.time),
                interval: .seconds(.greatestFiniteMagnitude))
            {
                self.lock.lock()
                guard self.state.isRelaying else {
                    self.lock.unlock()
                    return
                }
                
                let buffer = self.buffer
                self.buffer.removeAll(keepingCapacity: true)
                self.lock.unlock()
                self.rescheduleTimeout()
            
                let more = self.sub.receive(buffer)
                
                guard more > 0 else { return }
                
                self.lock.lock()
                guard let subscription = self.state.subscription else {
                    self.lock.unlock()
                    return
                }
                subscription.request(more)
            }
            self.lock.unlock()
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
            
            self.buffer.append(input)
            
            switch self.buffer.count {
            case self.count:
                let output = self.buffer
                self.buffer.removeAll(keepingCapacity: true)
                self.lock.unlock()
                self.rescheduleTimeout()
                return self.sub.receive(output)
            default:
                self.lock.unlock()
                return .max(1)
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            
            if self.buffer.isNotEmpty {
                let output = self.buffer
                self.buffer = []
                _ = self.sub.receive(output)
            }
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "CollectByTime"
        }
        
        var debugDescription: String {
            return "CollectByTime"
        }
    }
}
