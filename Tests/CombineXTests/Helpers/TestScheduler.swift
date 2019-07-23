#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

import Foundation

private let counter = Atom<Int>(val: 0)

final class TestScheduler: Scheduler {

    typealias SchedulerTimeType = TestSchedulerTime
    enum SchedulerOptions {
        case x
    }
    
    private final class Action {
        let time: SchedulerTimeType
        let id: Int
        let action: () -> Void
        
        init(time: SchedulerTimeType, action: @escaping () -> Void) {
            self.time = time
            self.action = action
            self.id = counter.add(1)
        }
        
        class func < (_ a: Action, _ b: Action) -> Bool {
            if a.time == b.time {
                return a.id < b.id
            }
            return a.time < b.time
        }
    }
    
    private let lock = Lock(recursive: true)
    private var scheduledActions: [Action] = []
    
    private var _now: SchedulerTimeType
    
    var now: SchedulerTimeType {
        return self.lock.withLockGet(self._now)
    }
    
    let minimumTolerance: TestSchedulerTime.Stride = .seconds(0)
    
    init(time: SchedulerTimeType = SchedulerTimeType(time: Date(timeIntervalSinceReferenceDate: 0))) {
        self._now = time
    }
    
    func schedule(options: TestScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        let action = Action(time: self._now, action: action)
        self.scheduledActions.append(action)
        self.scheduledActions.sort(by: <)
        self.lock.unlock()
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        let action = Action(time: date, action: action)
        self.scheduledActions.append(action)
        self.scheduledActions.sort(by: <)
        self.lock.unlock()
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        self.lock.lock()
        let action = Action(time: date) {
            action()
            self.schedule(after: self.now.advanced(by: interval), tolerance: tolerance, options: options, action)
        }
        self.scheduledActions.append(action)
        self.scheduledActions.sort(by: <)
        self.lock.unlock()
        
        return AnyCancellable {
            self.lock.lock()
            self.scheduledActions = self.scheduledActions.filter { $0 !== action }
            self.lock.unlock()
        }
    }
    
    func advance(to time: SchedulerTimeType) {
        self.lock.lock()
        
        while let first = self.scheduledActions.first {
            if time < first.time {
                break
            }
            
            self._now = first.time
        
            let action = self.scheduledActions.remove(at: 0)
            action.action()
        }
        
        self._now = time
        self.lock.unlock()
    }
    
    func advance(by interval: SchedulerTimeType.Stride) {
        self.lock.lock()
        self.advance(to: self._now.advanced(by: interval))
        self.lock.unlock()
    }
}
