#if !COCOAPODS
import CXUtility
#endif

extension Publisher {
    
    /// Specifies the scheduler on which to perform subscribe, cancel, and request operations.
    ///
    /// In contrast with `receive(on:options:)`, which affects downstream messages,
    /// `subscribe(on:)` changes the execution context of upstream messages. In the following
    /// example, requests to `jsonPublisher` are performed on `backgroundQueue`, but elements
    /// received from it are performed on `RunLoop.main`.
    ///
    ///     let ioPerformingPublisher == // Some publisher.
    ///     let uiUpdatingSubscriber == // Some subscriber that updates the UI.
    ///
    ///     ioPerformingPublisher
    ///         .subscribe(on: backgroundQueue)
    ///         .receiveOn(on: RunLoop.main)
    ///         .subscribe(uiUpdatingSubscriber)
    ///
    /// - Parameters:
    ///   - scheduler: The scheduler on which to receive upstream messages.
    ///   - options: Options that customize the delivery of elements.
    /// - Returns: A publisher which performs upstream operations on the specified scheduler.
    public func subscribe<S: Scheduler>(on scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.SubscribeOn<Self, S> {
        return .init(upstream: self, scheduler: scheduler, options: options)
    }
}

extension Publishers {
    
    /// A publisher that receives elements from an upstream publisher on a specific scheduler.
    public struct SubscribeOn<Upstream: Publisher, Context: Scheduler>: Publisher {
        
        public typealias Output = Upstream.Output
        
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The scheduler the publisher should use to receive elements.
        public let scheduler: Context
        
        /// Scheduler options that customize the delivery of elements.
        public let options: Context.SchedulerOptions?
        
        public init(upstream: Upstream, scheduler: Context, options: Context.SchedulerOptions?) {
            self.upstream = upstream
            self.scheduler = scheduler
            self.options = options
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            let s = Inner(pub: self, sub: subscriber)
            self.upstream.subscribe(s)
        }
    }
}

extension Publishers.SubscribeOn {
    
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
        
        typealias Pub = Publishers.SubscribeOn<Upstream, Context>
        typealias Sub = S
        typealias Transform = (Upstream.Output) throws -> Output?
        
        let lock = Lock()
        let scheduler: Context
        let options: Context.SchedulerOptions?
        let sub: Sub
        
        var state = RelayState.waiting
        
        init(pub: Pub, sub: Sub) {
            self.scheduler = pub.scheduler
            self.options = pub.options
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard let subscription = self.lock.withLockGet(self.state.subscription) else {
                return
            }
            self.scheduler.schedule(options: self.options) {
                subscription.request(demand)
            }
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
            return "ReceiveOn"
        }
        
        var debugDescription: String {
            return "ReceiveOn"
        }
    }
}
