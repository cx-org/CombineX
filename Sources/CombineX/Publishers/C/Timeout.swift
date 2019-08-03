extension Publisher {

    /// Terminates publishing if the upstream publisher exceeds the specified time interval without producing an element.
    ///
    /// - Parameters:
    ///   - interval: The maximum time interval the publisher can go without emitting an element, expressed in the time system of the scheduler.
    ///   - scheduler: The scheduler to deliver events on.
    ///   - options: Scheduler options that customize the delivery of elements.
    ///   - customError: A closure that executes if the publisher times out. The publisher sends the failure returned by this closure to the subscriber as the reason for termination.
    /// - Returns: A publisher that terminates if the specified interval elapses with no events received from the upstream publisher.
    public func timeout<S>(_ interval: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil, customError: (() -> Self.Failure)? = nil) -> Publishers.Timeout<Self, S> where S : Scheduler {
        return .init(upstream: self, interval: interval, scheduler: scheduler, options: options, customError: customError)
    }
}

extension Publishers {

    public struct Timeout<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        public let upstream: Upstream

        public let interval: Context.SchedulerTimeType.Stride

        public let scheduler: Context

        public let options: Context.SchedulerOptions?

        public let customError: (() -> Upstream.Failure)?
        
        public init(upstream: Upstream, interval: Context.SchedulerTimeType.Stride, scheduler: Context, options: Context.SchedulerOptions?, customError: (() -> Publishers.Timeout<Upstream, Context>.Failure)?) {
            self.upstream = upstream
            self.interval = interval
            self.scheduler = scheduler
            self.options = options
            self.customError = customError
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.Timeout {
    
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
        
        typealias Pub = Publishers.Timeout<Upstream, Context>
        typealias Sub = S
        
        let lock = Lock(recursive: true)
        let interval: Context.SchedulerTimeType.Stride
        let scheduler: Context
        let options: Context.SchedulerOptions?
        let customError: (() -> Upstream.Failure)?
        let sub: Sub
        
        var state = RelayState.waiting
        var timeoutTask: Cancellable?
        
        init(pub: Pub, sub: Sub) {
            self.interval = pub.interval
            self.scheduler = pub.scheduler
            self.options = pub.options
            self.customError = pub.customError
            self.sub = sub
            
            self.rescheduleTimeoutTask()
        }
        
        private func schedule(after interval: Context.SchedulerTimeType.Stride, action: @escaping () -> Void) -> Cancellable {
            return self.scheduler.schedule(
                after: self.scheduler.now.advanced(by: interval),
                interval: .seconds(Int.max),
                tolerance: self.scheduler.minimumTolerance,
                options: self.options,
                action
            )
        }
        
        func rescheduleTimeoutTask() {
            self.lock.lock()
            self.timeoutTask?.cancel()
            self.timeoutTask = self.schedule(after: self.interval) {
                self.lock.lock()
                guard self.state.isRelaying else {
                    self.lock.unlock()
                    return
                }
                
                let subscription = self.state.complete()
                self.lock.unlock()
                
                subscription?.cancel()
                
                if let error = self.customError?() {
                    self.sub.receive(completion: .failure(error))
                } else {
                    self.sub.receive(completion: .finished)
                }
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
            guard self.lock.withLockGet(self.state.isRelaying) else {
                return .none
            }
            
            defer {
                self.rescheduleTimeoutTask()
            }
            return self.sub.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard let subscription = self.lock.withLockGet(self.state.complete()) else {
                return
            }
            subscription.cancel()
            self.sub.receive(completion: completion)
        }
        
        var description: String {
            return "Timeout"
        }
        
        var debugDescription: String {
            return "Timeout"
        }
    }

}

