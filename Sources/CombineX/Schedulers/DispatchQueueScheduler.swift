import Dispatch

public struct DispatchScheduler: Scheduler {

    public struct SchedulerTimeType: Strideable {
        
        public var time: DispatchTime
        
        public func distance(to other: SchedulerTimeType) -> Stride {
            let distance = self.time.uptimeNanoseconds.distance(to: other.time.uptimeNanoseconds)
            return Stride.nanoseconds(distance)
        }
        
        public func advanced(by n: Stride) -> SchedulerTimeType {
            let advanced = self.time + n.seconds
            return SchedulerTimeType(time: advanced)
        }
        
        public static var now: SchedulerTimeType {
            return SchedulerTimeType(time: .now())
        }
        
        public struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {
            
            public typealias Magnitude = Double
            
            public var seconds: Double
            
            public var magnitude: Double {
                return self.seconds.magnitude
            }
            
            public init(integerLiteral value: Int) {
                self.seconds = Double(value)
            }
            
            public init(floatLiteral value: Double) {
                self.seconds = value
            }
            
            public init?<T>(exactly source: T) where T : BinaryInteger {
                guard let v = Double(exactly: source) else {
                    return nil
                }
                self.seconds = v
            }
            
            public static func < (lhs: Stride, rhs: Stride) -> Bool {
                return lhs.seconds < rhs.seconds
            }
            
            public static func * (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(floatLiteral: lhs.seconds * rhs.seconds)
            }
            
            public static func + (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(floatLiteral: lhs.seconds + rhs.seconds)
            }
            
            public static func - (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(floatLiteral: lhs.seconds - rhs.seconds)
            }
            
            public static func -= (lhs: inout Stride, rhs: Stride) {
                lhs = lhs - rhs
            }
            
            public static func *= (lhs: inout Stride, rhs: Stride) {
                lhs = lhs * rhs
            }
            
            public static func += (lhs: inout Stride, rhs: Stride) {
                lhs = lhs + rhs
            }
            
            public static func seconds(_ s: Int) -> Stride {
                return Stride(integerLiteral: s)
            }
            
            public static func seconds(_ s: Double) -> Stride {
                return Stride(floatLiteral: s)
            }
            
            public static func milliseconds(_ ms: Int) -> Stride {
                return Stride(floatLiteral: Double(ms) / Double(Const.msec_per_sec))
            }
            
            public static func microseconds(_ us: Int) -> Stride {
                return Stride(floatLiteral: Double(us) / Double(Const.usec_per_sec))
            }
            
            public static func nanoseconds(_ ns: Int) -> Stride {
                return Stride(floatLiteral: Double(ns) / Double(Const.nsec_per_sec))
            }
            
            public static var zero: Stride {
                return Stride.seconds(0)
            }
        }
    }
    
    public typealias SchedulerOptions = DispatchWorkItemFlags
    
    let dispatchQueue: DispatchQueue
    
    public init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }
    
    public static let main = DispatchScheduler(dispatchQueue: .main)
    
    public static func serial(label: String) -> DispatchScheduler {
        return DispatchScheduler(dispatchQueue: DispatchQueue(label: label))
    }
    
    public static func global(qos: DispatchQoS.QoSClass = .default) -> DispatchScheduler {
        return DispatchScheduler(dispatchQueue: DispatchQueue.global(qos: qos))
    }
    
    public let minimumTolerance: SchedulerTimeType.Stride = .seconds(0)
    
    public var now: SchedulerTimeType {
        return SchedulerTimeType(time: .now())
    }
    
    public func schedule(options: DispatchWorkItemFlags?, _ action: @escaping () -> Void) {
        self.dispatchQueue.async(flags: options ?? [], execute: action)
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        let timer = DispatchSource.makeTimerSource()
        
        var ref: DispatchSourceTimer? = timer
        
        timer.setEventHandler(flags: options ?? []) {
            action()
             
            ref?.cancel()
            ref = nil
        }
        
        let leeway = Int(Swift.max(tolerance, self.minimumTolerance).seconds * Double(Const.nsec_per_sec))
        timer.schedule(deadline: date.time, leeway: .nanoseconds(leeway))
        timer.resume()
    }
    
    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        
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
