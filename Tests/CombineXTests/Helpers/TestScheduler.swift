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
    
    private final class ScheduledAction {
        let time: SchedulerTimeType
        let id: Int
        let action: () -> Void
        
        init(time: SchedulerTimeType, action: @escaping () -> Void) {
            self.time = time
            self.action = action
            self.id = counter.add(1)
        }
        
        class func < (_ a: ScheduledAction, _ b: ScheduledAction) -> Bool {
            if a.time == b.time {
                return a.id < b.id
            }
            return a.time < b.time
        }
    }
    
    private let lock = Lock(recursive: true)
    private var scheduledActions: [ScheduledAction] = []
    
    private var _now: SchedulerTimeType
    
    var now: SchedulerTimeType {
        return self.lock.withLockGet(self._now)
    }
    
    let minimumTolerance: TestSchedulerTime.Stride = .seconds(0)
    
    var isLogEnabled = false
    
    init() {
        self._now = SchedulerTimeType(time: Date())
    }
    
    func schedule(options: TestScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        if self.isLogEnabled {
            print("TestScheduler: schedule")
        }
        
        let scheduledAction = ScheduledAction(time: self._now, action: action)
        self.scheduledActions.append(scheduledAction)
        self.scheduledActions.sort(by: <)
        self.lock.unlock()
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.lock.lock()
        if self.isLogEnabled {
            print("TestScheduler: schedule after \(date)")
        }
        let scheduledAction = ScheduledAction(time: date, action: action)
        self.scheduledActions.append(scheduledAction)
        self.scheduledActions.sort(by: <)
        self.lock.unlock()
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        self.lock.lock()
        if self.isLogEnabled {
            print("TestScheduler: schedule after \(date), interval \(interval)")
        }

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

        return box
    }
    
    func advance(to time: SchedulerTimeType) {
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
    
    func advance(by interval: SchedulerTimeType.Stride) {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        self.advance(to: self._now.advanced(by: interval))
    }

//    func advanceGradually(by interval: SchedulerTimeType.Stride, step: SchedulerTimeType.Stride) {
//        self.lock.lock()
//        defer {
//            self.lock.unlock()
//        }
//        guard step < interval else {
//            self.advance(by: interval)
//            return
//        }
//
//        var start = step
//        while (start + step) < interval {
//            self.advance(by: step)
//            start += step
//        }
//        self.advance(by: interval - start)
//    }
}
