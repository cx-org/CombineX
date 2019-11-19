import CombineX
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    public final class OperationQueue: NSObject<Foundation.OperationQueue> {}
}

extension OperationQueue {
    
    public typealias CX = CXWrappers.OperationQueue
    
    public var cx: CXWrappers.OperationQueue {
        return CXWrappers.OperationQueue(wrapping: self)
    }
}

extension CXWrappers.OperationQueue: CombineX.Scheduler {
    
    public typealias SchedulerTimeType = CXWrappers.RunLoop.SchedulerTimeType
    
    public typealias SchedulerOptions = CXWrappers.RunLoop.SchedulerOptions
    
    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.base.addOperation {
            action()
        }
    }
    
    public var now: SchedulerTimeType {
        return .init(Date())
    }
    
    public var minimumTolerance: SchedulerTimeType.Stride {
        return .init(0)
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        
        let s = DispatchQueue.global().cx
        let d = s.now.advanced(by: .seconds(date.date.timeIntervalSinceNow))
        s.schedule(after: d, tolerance: .seconds(tolerance.timeInterval)) {
            self.base.addOperation {
                action()
            }
        }
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        let s = DispatchQueue.global().cx
        let d = s.now.advanced(by: .seconds(date.date.timeIntervalSinceNow))
        let task = s.schedule(after: d, interval: .seconds(interval.timeInterval), tolerance: .seconds(tolerance.timeInterval)) {
            self.base.addOperation {
                action()
            }
        }
        
        return AnyCancellable {
            task.cancel()
        }
    }
}
