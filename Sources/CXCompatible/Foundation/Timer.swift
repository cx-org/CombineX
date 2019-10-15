#if canImport(Foundation) && canImport(Combine)
import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineXWrapper where Base: Timer {

    /// Returns a publisher that repeatedly emits the current date on the given interval.
    ///
    /// - Parameters:
    ///   - interval: The time interval on which to publish events. For example, a value of `0.5` publishes an event approximately every half-second.
    ///   - tolerance: The allowed timing variance when emitting events. Defaults to `nil`, which allows any variance.
    ///   - runLoop: The run loop on which the timer runs.
    ///   - mode: The run loop mode in which to run the timer.
    ///   - options: Scheduler options passed to the timer. Defaults to `nil`.
    /// - Returns: A publisher that repeatedly emits the current date on the given interval.
    public static func publish(every interval: TimeInterval, tolerance: TimeInterval? = nil, on runLoop: RunLoop, in mode: RunLoop.Mode, options: RunLoopCXWrapper.SchedulerOptions? = nil) -> Timer.CX.TimerPublisher {
        return .init(interval: interval, tolerance: tolerance, runLoop: runLoop, mode: mode, options: options)
    }
    
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Timer.CX {
    
    /// A publisher that repeatedly emits the current date on a given interval.
    public typealias TimerPublisher = Timer.TimerPublisher
}

#endif
