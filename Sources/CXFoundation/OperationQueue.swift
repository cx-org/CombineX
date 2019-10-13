import CombineX
import Foundation

public typealias OperationQueueCXWrapper = OperationQueue.OperationQueueCXWrapper

extension CombineXCompatible where Self: OperationQueue {
    
    public var cx: OperationQueueCXWrapper {
        return OperationQueueCXWrapper(self)
    }
    
    public static var cx: OperationQueueCXWrapper.Type {
        return OperationQueueCXWrapper.self
    }
}

extension OperationQueue {
    
    public class OperationQueueCXWrapper: AnyObjectCXWrapper<OperationQueue>, CombineX.Scheduler {
        
        /// Describes an instant in time for this scheduler.
        public typealias SchedulerTimeType = RunLoopCXWrapper.SchedulerTimeType

        /// A type that defines options accepted by the scheduler.
        ///
        /// This type is freely definable by each `Scheduler`. Typically, operations that take a `Scheduler` parameter will also take `SchedulerOptions`.
        public typealias SchedulerOptions = RunLoopCXWrapper.SchedulerOptions

        /// Performs the action at the next possible opportunity.
        public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            self.base.addOperation {
                action()
            }
        }

        /// Returns this scheduler's definition of the current moment in time.
        public var now: SchedulerTimeType {
            return .init(Date())
        }

        /// Returns the minimum tolerance allowed by the scheduler.
        public var minimumTolerance: SchedulerTimeType.Stride {
            return .init(0)
        }

        /// Performs the action at some time after the specified date.
        public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            
            let s = DispatchQueue.global().cx
            let d = s.now.advanced(by: .seconds(date.date.timeIntervalSinceNow))
            s.schedule(after: d, tolerance: .seconds(tolerance.timeInterval)) {
                self.base.addOperation {
                    action()
                }
            }
        }

        /// Performs the action at some time after the specified date, at the specified
        /// frequency, optionally taking into account tolerance if possible.
        public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
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
}
