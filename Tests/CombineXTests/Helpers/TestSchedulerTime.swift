import Foundation

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

struct TestSchedulerTime: Strideable {
    
    let time: Date
    
    init(time: Date) {
        self.time = time
    }
    
    func distance(to other: TestSchedulerTime) -> Stride {
        let distance = other.time.timeIntervalSince(self.time)
        return Stride.seconds(distance)
    }
    
    func advanced(by n: Stride) -> TestSchedulerTime {
        let advanced = self.time + n.seconds
        return TestSchedulerTime(time: advanced)
    }
    
    static var now: TestSchedulerTime {
        return TestSchedulerTime(time: Date())
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


extension TestSchedulerTime: CustomStringConvertible {
    
    var description: String {
        return self.time.timeIntervalSinceReferenceDate.description
    }
}

extension TestSchedulerTime.Stride: CustomStringConvertible {
    
    var description: String {
        return self.seconds.description
    }
}
