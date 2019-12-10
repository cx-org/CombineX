/// A scheduler for performing synchronous actions.
///
/// You can use this scheduler for immediate actions. If you attempt to schedule actions after a specific date, the scheduler ignores the date and executes synchronously.
public struct ImmediateScheduler: Scheduler {
    
    /// The time type used by the immediate scheduler.
    public struct SchedulerTimeType: Strideable {
        
        /// Returns the distance to another immediate scheduler time; this distance is always `0` in the context of an immediate scheduler.
        ///
        /// - Parameter other: The other scheduler time.
        /// - Returns: `0`, as a `Stride`.
        public func distance(to other: SchedulerTimeType) -> Stride {
            return Stride(0)
        }
        
        /// Advances the time by the specified amount; this is meaningless in the context of an immediate scheduler.
        ///
        /// - Parameter n: The amount to advance by. The `ImmediateScheduler` ignores this value.
        /// - Returns: An empty `SchedulerTimeType`.
        public func advanced(by n: Stride) -> SchedulerTimeType {
            return self
        }
        
        /// The increment by which the immediate scheduler counts time.
        public struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {
            
            public var magnitude: Int

            public init(_ value: Int) {
                self.magnitude = value
            }
            
            public init(integerLiteral value: Int) {
                self.magnitude = value
            }
            
            public init(floatLiteral value: Double) {
                self.magnitude = Int(value)
            }
            
            public init?<T: BinaryInteger>(exactly source: T) {
                guard let v = Int(exactly: source) else {
                    return nil
                }
                self.magnitude = v
            }
            
            public static func < (lhs: Stride, rhs: Stride) -> Bool {
                return lhs.magnitude < rhs.magnitude
            }
            
            public static func + (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(integerLiteral: lhs.magnitude + rhs.magnitude)
            }
            
            public static func += (lhs: inout Stride, rhs: Stride) {
                lhs.magnitude += rhs.magnitude
            }
            
            public static func - (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(integerLiteral: lhs.magnitude - rhs.magnitude)
            }
            
            public static func -= (lhs: inout Stride, rhs: Stride) {
                lhs.magnitude -= rhs.magnitude
            }
            
            public static func * (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(integerLiteral: lhs.magnitude * rhs.magnitude)
            }
            
            public static func *= (lhs: inout Stride, rhs: Stride) {
                lhs.magnitude *= rhs.magnitude
            }
            
            public static func seconds(_ s: Int) -> Stride {
                return Stride(0)
            }
            
            public static func seconds(_ s: Double) -> Stride {
                return Stride(0)
            }
            
            public static func milliseconds(_ ms: Int) -> Stride {
                return Stride(0)
            }
            
            public static func microseconds(_ us: Int) -> Stride {
                return Stride(0)
            }
            
            public static func nanoseconds(_ ns: Int) -> Stride {
                return Stride(0)
            }
        }
    }
    
    public typealias SchedulerOptions = Never
    
    /// The shared instance of the immediate scheduler.
    ///
    /// You cannot create instances of the immediate scheduler yourself. Use only the shared instance.
    public static let shared: ImmediateScheduler = ImmediateScheduler()
    
    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }
    
    public var now: SchedulerTimeType {
        return SchedulerTimeType()
    }
    
    public var minimumTolerance: SchedulerTimeType.Stride {
        return SchedulerTimeType.Stride(0)
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        action()
        return AnyCancellable {}
    }
}
