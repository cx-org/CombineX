#if USE_COMBINE
import Combine
#else
import CombineX
#endif

import Foundation

class TestDispatchQueueScheduler: Scheduler {
    
    typealias SchedulerTimeType = TestSchedulerTime
    typealias SchedulerOptions = Never
    
    let dispatchQueue: DispatchQueue
    
    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    let minimumTolerance: SchedulerTimeType.Stride = .seconds(0)
    
    var now: SchedulerTimeType {
        return SchedulerTimeType.now
    }
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.dispatchQueue.async(execute: action)
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        let timer = DispatchSource.makeTimerSource(queue: self.dispatchQueue)
        
        var hold: DispatchSourceTimer? = timer
        
        timer.setEventHandler() {
            action()
            
            hold?.cancel()
            hold = nil
        }
        
        let leeway = (Swift.max(tolerance, self.minimumTolerance).seconds * Double(Const.nsec_per_sec)).clampedToInt
        timer.schedule(deadline: DispatchTime.now() + date.time.timeIntervalSinceNow, leeway: .nanoseconds(leeway))
        timer.resume()
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        
        let timer = DispatchSource.makeTimerSource(queue: self.dispatchQueue)
        
        timer.setEventHandler() {
            action()
        }
        
        let repeating = (interval.seconds * Double(Const.nsec_per_sec)).clampedToInt
        let leeway = (Swift.max(tolerance, self.minimumTolerance).seconds * Double(Const.nsec_per_sec)).clampedToInt
        timer.schedule(deadline: DispatchTime.now() + date.time.timeIntervalSinceNow, repeating: .nanoseconds(repeating), leeway: .nanoseconds(leeway))
        timer.resume()
        
        return AnyCancellable {
            timer.cancel()
        }
    }
}

extension TestDispatchQueueScheduler {
    
    class var main: TestDispatchQueueScheduler {
        return TestDispatchQueueScheduler(dispatchQueue: .main)
    }
    
    class func serial(label: String = UUID().uuidString) -> TestDispatchQueueScheduler {
        return TestDispatchQueueScheduler(dispatchQueue: DispatchQueue(label: label))
    }
    
    class func global(qos: DispatchQoS.QoSClass = .default) -> TestDispatchQueueScheduler {
        return TestDispatchQueueScheduler(dispatchQueue: DispatchQueue.global(qos: qos))
    }
}


extension TestDispatchQueueScheduler {
    
    var isCurrent: Bool {
        return self.dispatchQueue.isCurrent
    }
}
