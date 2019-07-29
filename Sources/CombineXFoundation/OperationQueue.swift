import CombineX
import Foundation

extension OperationQueue: CombineXCompatible { }

extension OperationQueue {
    
    public enum CombineX {
    }
}

extension CombineXBox where Base: OperationQueue {
    
    var scheduler: OperationQueue.CombineX.Scheduler {
        return .init(self.base)
    }
}

extension OperationQueue.CombineX {
    
    public struct Scheduler: CombineX.Scheduler {
        
        let q: OperationQueue
        
        init(_ q: OperationQueue) {
            self.q = q
        }
        
        /// Describes an instant in time for this scheduler.
        public typealias SchedulerTimeType = RunLoop.CombineX.Scheduler.SchedulerTimeType

        /// A type that defines options accepted by the scheduler.
        ///
        /// This type is freely definable by each `Scheduler`. Typically, operations that take a `Scheduler` parameter will also take `SchedulerOptions`.
        public typealias SchedulerOptions = RunLoop.CombineX.Scheduler.SchedulerOptions

        /// Performs the action at the next possible opportunity.
        public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            self.q.addOperation {
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
            
            let s = DispatchQueue.global().cx.scheduler
            let d = s.now.advanced(by: .seconds(date.date.timeIntervalSinceNow))
            s.schedule(after: d, tolerance: .seconds(tolerance.timeInterval)) {
                self.q.addOperation {
                    action()
                }
            }
        }

        /// Performs the action at some time after the specified date, at the specified
        /// frequency, optionally taking into account tolerance if possible.
        public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            let op = BlockOperation(block: action)
            
            let s = DispatchQueue.global().cx.scheduler
            let d = s.now.advanced(by: .seconds(date.date.timeIntervalSinceNow))
            let task = s.schedule(after: d, interval: .seconds(interval.timeInterval), tolerance: .seconds(tolerance.timeInterval)) {
                self.q.addOperation {
                    action()
                }
            }
            
            return AnyCancellable {
                op.cancel()
                task.cancel()
            }
        }
    }
}
