import CXShim
import CXUtility
import Foundation

public class TestDispatchQueueScheduler: Scheduler {
    
    public typealias SchedulerTimeType = VirtualTime
    public typealias SchedulerOptions = Never
    
    public let dispatchQueue: DispatchQueue
    
    public init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    public let minimumTolerance: SchedulerTimeType.Stride = .seconds(0)
    
    public var now: SchedulerTimeType {
        return SchedulerTimeType.now
    }
    
    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.dispatchQueue.async(execute: action)
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void)
    {
        let timer = DispatchSource.makeTimerSource(queue: self.dispatchQueue)
        
        var hold: DispatchSourceTimer? = timer
        
        timer.setEventHandler {
            action()
            
            hold?.cancel()
            hold = nil
        }
        
        let leeway = (Swift.max(tolerance, self.minimumTolerance).seconds * Double(Const.nsec_per_sec)).clampedToInt
        timer.schedule(deadline: DispatchTime.now() + date.time.timeIntervalSinceNow, leeway: .nanoseconds(leeway))
        timer.resume()
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        let timer = DispatchSource.makeTimerSource(queue: self.dispatchQueue)
        
        timer.setEventHandler {
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

public extension TestDispatchQueueScheduler {
    
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

public extension TestDispatchQueueScheduler {
    
    var isCurrent: Bool {
        return self.dispatchQueue.isCurrent
    }
}
