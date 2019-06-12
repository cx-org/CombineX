import Foundation
import Dispatch

#if CombineQ
import CombineQ
#else
import Combine
#endif

class DispatchQueueScheduler: Scheduler {
    
    let queue: DispatchQueue
    
    init(_ queue: DispatchQueue) {
        self.queue = queue
    }
    
    typealias SchedulerTimeType = UInt64
    
    typealias SchedulerOptions = Never
    
    var now: UInt64 {
        return DispatchTime.now().uptimeNanoseconds
    }
    
    var minimumTolerance: UInt64.Stride {
        return 0
    }
    
    func schedule(options: Never?, _ action: @escaping () -> Void) {
        self.queue.async(execute: action)
    }
    
    func schedule(after date: UInt64, tolerance: UInt64.Stride, options: Never?, _ action: @escaping () -> Void) {
        
        self.queue.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: date), execute: action)
    }
    
    func schedule(after date: UInt64, interval: UInt64.Stride, tolerance: UInt64.Stride, options: Never?, _ action: @escaping () -> Void) -> Cancellable {
        
        self.queue.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: date) + .nanoseconds(Int(interval)), execute: action)
        
        return AnyCancellable {
            print("[DispatchQueueScheduler] dispatch queue schedueler cancelled")
        }
    }
}

extension Int: SchedulerTimeIntervalConvertible {
}


