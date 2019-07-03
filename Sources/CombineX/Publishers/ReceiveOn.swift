extension Publisher {
    
    /// Specifies the scheduler on which to receive elements from the publisher.
    ///
    /// You use the `receive(on:options:)` operator to receive results on a specific scheduler, such as performing UI work on the main run loop.
    /// In contrast with `subscribe(on:options:)`, which affects upstream messages, `receive(on:options:)` changes the execution context of downstream messages. In the following example, requests to `jsonPublisher` are performed on `backgroundQueue`, but elements received from it are performed on `RunLoop.main`.
    ///
    ///     let jsonPublisher = MyJSONLoaderPublisher() // Some publisher.
    ///     let labelUpdater = MyLabelUpdateSubscriber() // Some subscriber that updates the UI.
    ///
    ///     jsonPublisher
    ///         .subscribe(on: backgroundQueue)
    ///         .receiveOn(on: RunLoop.main)
    ///         .subscribe(labelUpdater)
    ///
    /// - Parameters:
    ///   - scheduler: The scheduler the publisher is to use for element delivery.
    ///   - options: Scheduler options that customize the element delivery.
    /// - Returns: A publisher that delivers elements using the specified scheduler.
    public func receive<S>(on scheduler: S, options: S.SchedulerOptions? = nil) -> Publishers.ReceiveOn<Self, S> where S : Scheduler {
        return .init(upstream: self, scheduler: scheduler, options: options)
    }
}

extension Publishers {
    
    /// A publisher that delivers elements to its downstream subscriber on a specific scheduler.
    public struct ReceiveOn<Upstream, Context> : Publisher where Upstream : Publisher, Context : Scheduler {
        
        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output
        
        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure
        
        /// The publisher from which this publisher receives elements.
        public let upstream: Upstream
        
        /// The scheduler the publisher is to use for element delivery.
        public let scheduler: Context
        
        /// Scheduler options that customize the delivery of elements.
        public let options: Context.SchedulerOptions?
        
        public init(upstream: Upstream, scheduler: Context, options: Context.SchedulerOptions?) {
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
        public func receive<S>(subscriber: S) where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input {
            Global.RequiresImplementation()
        }
    }
}
