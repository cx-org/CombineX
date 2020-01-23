import CXShim
import CXUtility
import Foundation

private let counter = Atom<Int>(val: 0)

public final class VirtualTimeScheduler: Scheduler {

    public typealias SchedulerTimeType = VirtualTime
    public typealias SchedulerOptions = Never
    
    private final class ScheduledAction {
        let time: SchedulerTimeType
        let id: Int
        let action: () -> Void
        
        init(time: SchedulerTimeType, action: @escaping () -> Void) {
            self.time = time
            self.action = action
            self.id = counter.add(1)
        }
        
        static func < (_ a: ScheduledAction, _ b: ScheduledAction) -> Bool {
            if a.time == b.time {
                return a.id < b.id
            }
            return a.time < b.time
        }
    }
    
    private let lock = Lock(recursive: true)
    private var scheduledActions: [ScheduledAction] = []
    
    private var _now: SchedulerTimeType
    
    public var now: SchedulerTimeType {
        return self.lock.withLockGet(self._now)
    }
    
    public let minimumTolerance: VirtualTime.Stride = .seconds(0)
    
    public init() {
        self._now = SchedulerTimeType(time: Date())
    }
    
    public func schedule(options: VirtualTimeScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        let scheduledAction = ScheduledAction(time: self._now, action: action)
        self.scheduledActions.append(scheduledAction)
        self.scheduledActions.sort(by: <)
        self.lock.unlock()
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        let scheduledAction = ScheduledAction(time: date, action: action)
        self.scheduledActions.append(scheduledAction)
        self.scheduledActions.sort(by: <)
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
        self.scheduledActions.append(scheduledAction)
        self.scheduledActions.sort(by: <)
        self.lock.unlock()
        
        box.body = {
            self.lock.lock()
            self.scheduledActions = self.scheduledActions.filter { $0 !== scheduledAction }
            self.lock.unlock()
        }

        return AnyCancellable(box)
    }
    
    public func advance(to time: SchedulerTimeType) {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }

        while let first = self.scheduledActions.first {
            if time < first.time { break }
            
            self._now = first.time
        
            self.scheduledActions.remove(at: 0).action()
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
