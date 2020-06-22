import CXShim
import CXUtility

public final class VirtualTimeScheduler: Scheduler {

    public typealias SchedulerTimeType = VirtualTime
    public typealias SchedulerOptions = Never
    
    private final class ScheduledAction {
        
        private static let counter = LockedAtomic<Int>(0)
        
        let time: SchedulerTimeType
        let id: Int
        let action: () -> Void
        
        init(time: SchedulerTimeType, action: @escaping () -> Void) {
            self.time = time
            self.action = action
            self.id = ScheduledAction.counter.loadThenWrappingIncrement()
        }
        
        static func <(_ a: ScheduledAction, _ b: ScheduledAction) -> Bool {
            if a.time == b.time {
                return a.id < b.id
            }
            return a.time < b.time
        }
    }
    
    private let lock = RecursiveLock()
    private var scheduledActions = BinaryHeap<ScheduledAction>(sort: <)
    
    private var _now: SchedulerTimeType
    
    public var now: SchedulerTimeType {
        return self.lock.withLockGet(self._now)
    }
    
    public let minimumTolerance: VirtualTime.Stride = .seconds(0)
    
    public init(time: VirtualTime = .zero) {
        self._now = time
    }
    
    deinit {
        lock.cleanupLock()
    }
    
    public func schedule(options: VirtualTimeScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        let scheduledAction = ScheduledAction(time: self._now, action: action)
        self.scheduledActions.insert(scheduledAction)
        self.lock.unlock()
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        let scheduledAction = ScheduledAction(time: date, action: action)
        self.scheduledActions.insert(scheduledAction)
        self.lock.unlock()
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        self.lock.lock()
        
        class Box: Cancellable {
            var body: (() -> Void)? {
                willSet {
                    self.body?()
                }
            }
            func cancel() {
                self.body?()
            }
        }
        
        let box = Box()
        
        let scheduledAction = ScheduledAction(time: date) {
            action()
            
            let cancel = self.schedule(after: self._now.advanced(by: interval), interval: interval, tolerance: tolerance, options: options, action)
            box.body = {
                cancel.cancel()
            }
        }
        self.scheduledActions.insert(scheduledAction)
        self.lock.unlock()
        
        box.body = {
            self.lock.lock()
            self.scheduledActions.remove { $0 === scheduledAction }
            self.lock.unlock()
        }

        return AnyCancellable(box)
    }
    
    private func advance(to time: SchedulerTimeType) {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }

        while let first = self.scheduledActions.peek(), first.time <= time {
            assert(first === self.scheduledActions.remove())
            self._now = first.time
            first.action()
        }
        
        self._now = time
    }
    
    public func advance(by interval: SchedulerTimeType.Stride) {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        self.advance(to: self._now.advanced(by: interval))
    }
}
