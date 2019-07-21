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
            Global.RequiresImplementation()
        }
    }
}

