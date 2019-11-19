import CombineX
import Foundation

#if !COCOAPODS
import CXNamespace
import CXUtility
#endif

extension CXWrappers {
    
    public final class RunLoop: NSObject<Foundation.RunLoop> {}
}

extension RunLoop {
    
    public typealias CX = CXWrappers.RunLoop
    
    public var cx: CXWrappers.RunLoop {
        return CXWrappers.RunLoop(wrapping: self)
    }
}
    
extension CXWrappers.RunLoop: CombineX.Scheduler {
        
    /// The scheduler time type used by the run loop.
    public struct SchedulerTimeType: Strideable, Codable, Hashable {
        
        /// The date represented by this type.
        public var date: Date
        
        /// Initializes a run loop scheduler time with the given date.
        ///
        /// - Parameter date: The date to represent.
        public init(_ date: Date) {
            self.date = date
        }
        
        /// Returns the distance to another run loop scheduler time.
        ///
        /// - Parameter other: Another dispatch queue time.
        /// - Returns: The time interval between this time and the provided time.
        public func distance(to other: SchedulerTimeType) -> SchedulerTimeType.Stride {
            return .init(other.date.timeIntervalSince1970 - self.date.timeIntervalSince1970)
        }
        
        /// Returns a run loop scheduler time calculated by advancing this instance’s time by the given interval.
        ///
        /// - Parameter n: A time interval to advance.
        /// - Returns: A dispatch queue time advanced by the given interval from this instance’s time.
        public func advanced(by n: SchedulerTimeType.Stride) -> SchedulerTimeType {
            return .init(self.date.addingTimeInterval(n.timeInterval))
        }
        
        /// The interval by which run loop times advance.
        public struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {
            
            /// The value of this time interval in seconds.
            public var magnitude: TimeInterval
            
            /// The value of this time interval in seconds.
            public var timeInterval: TimeInterval {
                return self.magnitude
            }
            
            public init(integerLiteral value: TimeInterval) {
                self.magnitude = value
            }
            
            public init(floatLiteral value: TimeInterval) {
                self.magnitude = value
            }
            
            public init(_ timeInterval: TimeInterval) {
                self.magnitude = timeInterval
            }
            
            public init?<T: BinaryInteger>(exactly source: T) {
                guard let value = Double(exactly: source) else {
                    return nil
                }
                self.init(value)
            }
            
            public static func < (lhs: Stride, rhs: Stride) -> Bool {
                return lhs.magnitude < rhs.magnitude
            }
            
            public static func * (lhs: Stride, rhs: Stride) -> Stride {
                return .init(lhs.magnitude * rhs.magnitude)
            }
            
            public static func + (lhs: Stride, rhs: Stride) -> Stride {
                return .init(lhs.magnitude + rhs.magnitude)
            }
            
            public static func - (lhs: Stride, rhs: Stride) -> Stride {
                return .init(lhs.magnitude - rhs.magnitude)
            }
            
            public static func *= (lhs: inout Stride, rhs: Stride) {
                lhs = lhs * rhs
            }
            
            public static func += (lhs: inout Stride, rhs: Stride) {
                lhs = lhs + rhs
            }
            
            public static func -= (lhs: inout Stride, rhs: Stride) {
                lhs = lhs - rhs
            }
            
            public static func seconds(_ s: Int) -> Stride {
                return .init(Double(s))
            }
            
            public static func seconds(_ s: Double) -> Stride {
                return .init(s)
            }
            
            public static func milliseconds(_ ms: Int) -> Stride {
                return .init(Double(ms) / Double(Const.msec_per_sec))
            }
            
            public static func microseconds(_ us: Int) -> Stride {
                return .init(Double(us) / Double(Const.usec_per_sec))
            }
            
            public static func nanoseconds(_ ns: Int) -> Stride {
                return .init(Double(ns) / Double(Const.nsec_per_sec))
            }
        }
    }

    /// Options that affect the operation of the run loop scheduler.
    ///
    /// The run loop doesn’t support any scheduler options.
    public struct SchedulerOptions {
    }
    
    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.base.cx_perform {
            action()
        }
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        Timer.cx_scheduledTimer(withTimeInterval: self.now.distance(to: date).timeInterval, repeats: false) { _ in
            action()
        }
    }
    
    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        let timer = Timer.cx_init(fire: date.date, interval: interval.timeInterval, repeats: true) { _ in
            action()
        }
        self.base.add(timer, forMode: .default)
        return AnyCancellable {
            timer.invalidate()
        }
    }
    
    public var now: SchedulerTimeType {
      return .init(Date())
    }
    
    public var minimumTolerance: SchedulerTimeType.Stride {
      return .init(0)
    }
}
