import Foundation
import CXUtility
import CXShim

public struct TestSchedulerTime: Strideable {
    
    public let time: Date
    
    public init(time: Date) {
        self.time = time
    }
    
    public func distance(to other: TestSchedulerTime) -> Stride {
        let distance = other.time.timeIntervalSince(self.time)
        return Stride.seconds(distance)
    }
    
    public func advanced(by n: Stride) -> TestSchedulerTime {
        let advanced = self.time + n.seconds
        return TestSchedulerTime(time: advanced)
    }
    
    public static var now: TestSchedulerTime {
        return TestSchedulerTime(time: Date())
    }
    
    public struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {
        
        public typealias Magnitude = Double
        
        public let seconds: Double
        
        public init(seconds: Double) {
            self.seconds = seconds
        }
        
        public var magnitude: Double {
            return self.seconds.magnitude
        }
        
        public init(integerLiteral value: Int) {
            self.seconds = Double(value)
        }
        
        public init(floatLiteral value: Double) {
            self.seconds = value
        }
        
        public init?<T: BinaryInteger>(exactly source: T) {
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
            return Stride(floatLiteral: Double(ms) / Double(Const.usec_per_sec))
        }
        
        public static func microseconds(_ us: Int) -> Stride {
            return Stride(floatLiteral: Double(us) / Double(Const.msec_per_sec))
        }
        
        public static func nanoseconds(_ ns: Int) -> Stride {
            return Stride(floatLiteral: Double(ns) / Double(Const.nsec_per_sec))
        }
        
        public static var zero: Stride {
            return Stride.seconds(0)
        }
    }
}


extension TestSchedulerTime: CustomStringConvertible {
    
    public var description: String {
        return self.time.timeIntervalSinceReferenceDate.description
    }
}

extension TestSchedulerTime.Stride: CustomStringConvertible {
    
    public var description: String {
        return self.seconds.description
    }
}
