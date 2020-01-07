import CombineX
import CXUtility
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    public final class Timer: NSObject<Foundation.Timer> {}
}

extension Timer {
    
    public typealias CX = CXWrappers.Timer
    
    public var cx: CXWrappers.Timer {
        return CXWrappers.Timer(wrapping: self)
    }
}

extension CXWrappers.Timer {

    /// Returns a publisher that repeatedly emits the current date on the given interval.
    ///
    /// - Parameters:
    ///   - interval: The time interval on which to publish events. For example, a value of `0.5` publishes an event approximately every half-second.
    ///   - tolerance: The allowed timing variance when emitting events. Defaults to `nil`, which allows any variance.
    ///   - runLoop: The run loop on which the timer runs.
    ///   - mode: The run loop mode in which to run the timer.
    ///   - options: Scheduler options passed to the timer. Defaults to `nil`.
    /// - Returns: A publisher that repeatedly emits the current date on the given interval.
    public static func publish(
        every interval: TimeInterval,
        tolerance: TimeInterval? = nil,
        on runLoop: RunLoop,
        in mode: RunLoop.Mode,
        options: CXWrappers.RunLoop.SchedulerOptions? = nil
    ) -> TimerPublisher {
        return .init(interval: interval, tolerance: tolerance, runLoop: runLoop, mode: mode, options: options)
    }
}

extension CXWrappers.Timer {
    
    /// A publisher that repeatedly emits the current date on a given interval.
    public final class TimerPublisher: ConnectablePublisher {
        
        public typealias Output = Date
        
        public typealias Failure = Never
        
        public let interval: TimeInterval
        
        public let tolerance: TimeInterval?
        
        public let runLoop: RunLoop
        
        public let mode: RunLoop.Mode
        
        public let options: CXWrappers.RunLoop.SchedulerOptions?
        
        private lazy var routingSubscription = RoutingSubscription(parent: self)
        
        /// Creates a publisher that repeatedly emits the current date on the given interval.
        ///
        /// - Parameters:
        ///   - interval: The interval on which to publish events.
        ///   - tolerance: The allowed timing variance when emitting events. Defaults to `nil`, which allows any variance.
        ///   - runLoop: The run loop on which the timer runs.
        ///   - mode: The run loop mode in which to run the timer.
        ///   - options: Scheduler options passed to the timer. Defaults to `nil`.
        public init(interval: TimeInterval, tolerance: TimeInterval? = nil, runLoop: RunLoop, mode: RunLoop.Mode, options: CXWrappers.RunLoop.SchedulerOptions? = nil) {
            self.interval = interval
            self.tolerance = tolerance
            self.runLoop = runLoop
            self.mode = mode
            self.options = options
        }
        
        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            routingSubscription.receive(subscriber: subscriber)
        }
        
        public func connect() -> Cancellable {
            routingSubscription.connect()
            return routingSubscription
        }
    }
}

private extension CXWrappers.Timer.TimerPublisher {
    
    final class RoutingSubscription: Subscription, Subscriber {
        
        typealias Input = Date
        
        typealias Failure = Never
        
        private let lock = Lock()
        
        private var inner: Inner<RoutingSubscription>?
        
        private var subscribers: [AnySubscriber<Date, Never>] = []
        
        private var _lockedIsConnected = false
        
        init(parent: CXWrappers.Timer.TimerPublisher) {
            self.inner = Inner<RoutingSubscription>(downstream: self, parent: parent)
        }
        
        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            lock.lock()
            subscribers.append(AnySubscriber(subscriber))
            lock.unlock()
            subscriber.receive(subscription: self)
        }

        func connect() {
            lock.lock()
            guard _lockedIsConnected == false else {
                lock.unlock()
                return
            }
            _lockedIsConnected = true
            let inner = self.inner
            lock.unlock()
            inner?.start()
        }
        
        func receive(subscription: Subscription) {
            // Never receive subscription?
            fatalError()
        }
        
        func receive(_ input: Input) -> Subscribers.Demand {
            return lock.withLockGet(self.subscribers).reduce(into: Subscribers.Demand.none) { result, sub in
                // Not locked.
                // It's locked in Combine, but I don't think it's necessary. The whole invocation is locked by `Inner` anyway.
                result += sub.receive(input)
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            // Never complete?
            fatalError()
        }
        
        func request(_ demand: Subscribers.Demand) {
            inner?.request(demand)
        }
        
        func cancel() {
            lock.lock()
            guard _lockedIsConnected else {
                lock.unlock()
                return
            }
            _lockedIsConnected = false
            subscribers = []
            inner?.cancel()
            // inner = nil
            lock.unlock()
        }
    }
    
    final class Inner<Downstream: Subscriber>: NSObject, Subscription where Downstream.Input == Date, Downstream.Failure == Never {
        
        lazy var timer: Timer? = {
            guard let parent = parent else {
                return nil
            }
            let timer = Timer.cx_init(timeInterval: parent.interval, repeats: true) { [weak self] _ in
                self?.timerFired()
            }
            if let tolerance = parent.tolerance {
                timer.tolerance = tolerance
            }
            return timer
        }()
        
        let lock = Lock()
        
        var downstream: Downstream?
        
        var parent: CXWrappers.Timer.TimerPublisher?
        
        var started = false
        
        var demand = Subscribers.Demand.none
        
        init(downstream: Downstream, parent: CXWrappers.Timer.TimerPublisher) {
            self.downstream = downstream
            self.parent = parent
            super.init()
        }
        
        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            self.demand += demand
            lock.unlock()
        }
        
        func cancel() {
            lock.lock()
            guard let timer = timer else {
                lock.unlock()
                return
            }
            self.timer = nil
            downstream = nil
            parent = nil
            started = false
            lock.unlock()
            timer.invalidate()
        }
        
        func start() {
            lock.lock()
            guard started == false, let parent = parent, let timer = timer else {
                lock.unlock()
                return
            }
            started = true
            lock.unlock()
            parent.runLoop.add(timer, forMode: parent.mode)
        }
        
        func timerFired() {
            lock.lock()
            guard demand > 0 else {
                lock.unlock()
                return
            }
            demand -= 1
            if let downstream = self.downstream {
                // Should it be locked?
                // It's locked in Combine when receiving value, and result in surprising behaviour (to me).
                demand += downstream.receive(Date())
            }
            lock.unlock()
        }
    }
}
