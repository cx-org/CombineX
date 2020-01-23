import CXShim
import CXUtility

public struct VirtualTime: Strideable, Hashable, Comparable {
    
    public struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, SchedulerTimeIntervalConvertible {
        
        /// Time interval in nanoseconds.
        public var magnitude: Int
        
        init(magnitude: Int) {
            self.magnitude = magnitude
        }
        
        public init(integerLiteral value: Int) {
            self.magnitude = value * Const.nsec_per_sec
        }
        
        public init(floatLiteral value: Double) {
            self.magnitude = Int(value * Double(Const.nsec_per_sec))
        }
        
        public init?<T: BinaryInteger>(exactly source: T) {
            guard let value = Int(exactly: source) else {
                return nil
            }
            self.init(integerLiteral: value)
        }
        
        public static func < (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.magnitude < rhs.magnitude
        }
        
        public static func + (lhs: Stride, rhs: Stride) -> Stride {
            return Stride(magnitude: lhs.magnitude + rhs.magnitude)
        }
        
        public static func += (lhs: inout Stride, rhs: Stride) {
            lhs.magnitude += rhs.magnitude
        }
        
        public static func - (lhs: Stride, rhs: Stride) -> Stride {
            return Stride(magnitude: lhs.magnitude - rhs.magnitude)
        }
        
        public static func -= (lhs: inout Stride, rhs: Stride) {
            lhs.magnitude -= rhs.magnitude
        }
        
        public static func * (lhs: Stride, rhs: Stride) -> Stride {
            return Stride(magnitude: lhs.magnitude * rhs.magnitude)
        }
        
        public static func *= (lhs: inout Stride, rhs: Stride) {
            lhs.magnitude *= rhs.magnitude
        }
        
        public static func seconds(_ s: Double) -> Stride {
            return Stride(magnitude: Int(s * Double(Const.nsec_per_sec)))
        }
        
        public static func seconds(_ s: Int) -> Stride {
            return Stride(magnitude: s.multipliedClamping(by: Const.nsec_per_sec))
        }
        
        public static func milliseconds(_ ms: Int) -> Stride {
            return Stride(magnitude: ms.multipliedClamping(by: Const.nsec_per_msec))
        }
        
        public static func microseconds(_ us: Int) -> Stride {
            return Stride(magnitude: us.multipliedClamping(by: Const.nsec_per_usec))
        }
        
        public static func nanoseconds(_ ns: Int) -> Stride {
            return Stride(magnitude: ns)
        }
        
        public static var zero: Stride {
            return Stride.seconds(0)
        }
    }
    
    /// Time in nanoseconds.
    private let time: Int
    
    private init(nanoseconds time: Int) {
        self.time = time
    }
    
    public func distance(to other: VirtualTime) -> Stride {
        return Stride(magnitude: other.time - time)
    }
    
    public func advanced(by n: Stride) -> VirtualTime {
        return VirtualTime(nanoseconds: time.addingClamping(by: n.magnitude))
    }
    
    public static let zero = VirtualTime(nanoseconds: 0)
}
