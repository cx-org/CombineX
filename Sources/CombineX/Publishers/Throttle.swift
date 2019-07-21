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
            Global.RequiresImplementation()
        }
    }
}
