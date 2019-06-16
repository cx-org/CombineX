/// A protocol that defines when and how to execute a closure.
///
/// A scheduler used to execute code as soon as possible, or after a future date.
/// Individual scheduler implementations use whatever time-keeping system makes sense for them. Schdedulers express this as their `SchedulerTimeType`. Since this type conforms to `SchedulerTimeIntervalConvertible`, you can always express these times with the convenience functions like `.milliseconds(500)`.
/// Schedulers can accept options to control how they execute the actions passed to them. These options may control factors like which threads or dispatch queues execute the actions.
public protocol Scheduler {
    
    /// Describes an instant in time for this scheduler.
    associatedtype SchedulerTimeType : Strideable where Self.SchedulerTimeType.Stride : SchedulerTimeIntervalConvertible
    
    /// A type that defines options accepted by the scheduler.
    ///
    /// This type is freely definable by each `Scheduler`. Typically, operations that take a `Scheduler` parameter will also take `SchedulerOptions`.
    associatedtype SchedulerOptions
    
    /// Returns this scheduler's definition of the current moment in time.
    var now: Self.SchedulerTimeType { get }
    
    /// Returns the minimum tolerance allowed by the scheduler.
    var minimumTolerance: Self.SchedulerTimeType.Stride { get }
    
    /// Performs the action at the next possible opportunity.
    func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void)
    
    /// Performs the action at some time after the specified date.
    func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void)
    
    /// Performs the action at some time after the specified date, at the specified
    /// frequency, optionally taking into account tolerance if possible.
    func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable
}

extension Scheduler {
    
    /// Performs the action at some time after the specified date, using the scheduler’s minimum tolerance.
    public func schedule(after date: Self.SchedulerTimeType, _ action: @escaping () -> Void) {
        self.schedule(after: date, tolerance: self.minimumTolerance, action)
    }
    
    /// Performs the action at the next possible opportunity, without options.
    public func schedule(_ action: @escaping () -> Void) {
        self.schedule(options: nil, action)
    }
    
    /// Performs the action at some time after the specified date.
    public func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, _ action: @escaping () -> Void) {
        self.schedule(after: date, tolerance: tolerance, options: nil, action)
    }
    
    /// Performs the action at some time after the specified date, at the specified
    /// frequency, taking into account tolerance if possible.
    public func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Cancellable {
        return self.schedule(after: date, interval: interval, tolerance: tolerance, options: nil, action)
    }
    
    /// Performs the action at some time after the specified date, at the specified
    /// frequency, using minimum tolerance possible for this Scheduler.
    public func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Cancellable {
        return self.schedule(after: date, interval: interval, tolerance: self.minimumTolerance, action)
    }
}
