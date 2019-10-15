import CombineX
import Foundation

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

extension Timer.CX {
    
    /// A publisher that repeatedly emits the current date on a given interval.
    final public class TimerPublisher : ConnectablePublisher {

        /// The kind of values published by this publisher.
        public typealias Output = Date

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never

        final public let interval: TimeInterval

        final public let tolerance: TimeInterval?

        final public let runLoop: RunLoop

        final public let mode: RunLoop.Mode

        final public let options: RunLoopCXWrapper.SchedulerOptions?
        
        private typealias Subject = PassthroughSubject<Date, Never>
        private typealias Multicast = Publishers.Multicast<Subject, Subject>
        private let multicast: Multicast
        
        let timer: Timer

        /// Creates a publisher that repeatedly emits the current date on the given interval.
        ///
        /// - Parameters:
        ///   - interval: The interval on which to publish events.
        ///   - tolerance: The allowed timing variance when emitting events. Defaults to `nil`, which allows any variance.
        ///   - runLoop: The run loop on which the timer runs.
        ///   - mode: The run loop mode in which to run the timer.
        ///   - options: Scheduler options passed to the timer. Defaults to `nil`.
        public init(interval: TimeInterval, tolerance: TimeInterval? = nil, runLoop: RunLoop, mode: RunLoop.Mode, options: RunLoopCXWrapper.SchedulerOptions? = nil) {
            self.interval = interval
            self.tolerance = tolerance
            self.runLoop = runLoop
            self.mode = mode
            self.options = options
 
            let subject = Subject()
            self.multicast = subject.multicast(subject: Subject())
            
            self.timer = Timer.cx_init(timeInterval: self.interval, repeats: true) { _ in
                subject.send(Date())
            }
            self.runLoop.add(self.timer, forMode: self.mode)
        }

        deinit {
            self.timer.invalidate()
        }
        
        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        final public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Timer.CX.TimerPublisher.Failure, S.Input == Timer.CX.TimerPublisher.Output {
            self.multicast.receive(subscriber: subscriber)
        }

        /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
        ///
        /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
        final public func connect() -> Cancellable {
            return self.multicast.connect()
        }
    }
}
