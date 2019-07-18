#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

import Foundation

final class CustomScheduler: Scheduler {
    
    struct SchedulerTimeType: Strideable {
        
        let time: DispatchTime
        
        init(time: DispatchTime) {
            self.time = time
        }
        
        func distance(to other: SchedulerTimeType) -> Stride {
            let distance = self.time.uptimeNanoseconds.distance(to: other.time.uptimeNanoseconds)
            return Stride.nanoseconds(distance)
        }
        
        func advanced(by n: Stride) -> SchedulerTimeType {
            let advanced = self.time + n.seconds
            return SchedulerTimeType(time: advanced)
        }
        
        static var now: SchedulerTimeType {
            return SchedulerTimeType(time: .now())
        }
        
        struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {
            
            typealias Magnitude = Double
            
            let seconds: Double
            
            init(seconds: Double) {
                self.seconds = seconds
            }
            
            var magnitude: Double {
                return self.seconds.magnitude
            }
            
            init(integerLiteral value: Int) {
                self.seconds = Double(value)
            }
            
            init(floatLiteral value: Double) {
                self.seconds = value
            }
            
            init?<T>(exactly source: T) where T : BinaryInteger {
                guard let v = Double(exactly: source) else {
                    return nil
                }
                self.seconds = v
            }
            
            static func < (lhs: Stride, rhs: Stride) -> Bool {
                return lhs.seconds < rhs.seconds
            }
            
            static func * (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(floatLiteral: lhs.seconds * rhs.seconds)
            }
            
            static func + (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(floatLiteral: lhs.seconds + rhs.seconds)
            }
            
            static func - (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(floatLiteral: lhs.seconds - rhs.seconds)
            }
            
            static func -= (lhs: inout Stride, rhs: Stride) {
                lhs = lhs - rhs
            }
            
            static func *= (lhs: inout Stride, rhs: Stride) {
                lhs = lhs * rhs
            }
            
            static func += (lhs: inout Stride, rhs: Stride) {
                lhs = lhs + rhs
            }
            
            static func seconds(_ s: Int) -> Stride {
                return Stride(integerLiteral: s)
            }
            
            static func seconds(_ s: Double) -> Stride {
                return Stride(floatLiteral: s)
            }
            
            static func milliseconds(_ ms: Int) -> Stride {
                return Stride(floatLiteral: Double(ms) / Double(Const.msec_per_sec))
            }
            
            static func microseconds(_ us: Int) -> Stride {
                return Stride(floatLiteral: Double(us) / Double(Const.usec_per_sec))
            }
            
            static func nanoseconds(_ ns: Int) -> Stride {
                return Stride(floatLiteral: Double(ns) / Double(Const.nsec_per_sec))
            }
            
            static var zero: Stride {
                return Stride.seconds(0)
            }
        }
    }
    
    typealias SchedulerOptions = DispatchWorkItemFlags
    
    let dispatchQueue: DispatchQueue
    
    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    let minimumTolerance: SchedulerTimeType.Stride = .seconds(0)
    
    var now: SchedulerTimeType {
        return SchedulerTimeType(time: .now())
    }
    
    func schedule(options: DispatchWorkItemFlags?, _ action: @escaping () -> Void) {
        self.dispatchQueue.async(flags: options ?? [], execute: action)
    }
    
    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        let timer = DispatchSource.makeTimerSource()
        
        var hold: DispatchSourceTimer? = timer
        
        timer.setEventHandler(flags: options ?? []) {
            action()
            
            hold?.cancel()
            hold = nil
        }
        
        let leeway = Int(Swift.max(tolerance, self.minimumTolerance).seconds * Double(Const.nsec_per_sec))
        timer.schedule(deadline: date.time, leeway: .nanoseconds(leeway))
        timer.resume()
    }
    
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        
        let timer = DispatchSource.makeTimerSource()
        
        timer.setEventHandler(flags: options ?? []) {
            action()
        }
        
        let repeating = Int(interval.seconds * Double(Const.nsec_per_sec))
        let leeway = Int(Swift.max(tolerance, self.minimumTolerance).seconds * Double(Const.nsec_per_sec))
        timer.schedule(deadline: date.time, repeating: .nanoseconds(repeating), leeway: .nanoseconds(leeway))
        timer.resume()
        
        return AnyCancellable {
            timer.cancel()
        }
    }
}

extension CustomScheduler {
    
    class var main: CustomScheduler {
        return CustomScheduler(dispatchQueue: .main)
    }
    
    class func serial(label: String = UUID().uuidString) -> CustomScheduler {
        return CustomScheduler(dispatchQueue: DispatchQueue(label: label))
    }
    
    class func global(qos: DispatchQoS.QoSClass = .default) -> CustomScheduler {
        return CustomScheduler(dispatchQueue: DispatchQueue.global(qos: qos))
    }
}
