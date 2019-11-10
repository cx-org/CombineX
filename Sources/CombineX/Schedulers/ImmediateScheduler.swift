/// A scheduler for performing synchronous actions.
///
/// You can use this scheduler for immediate actions. If you attempt to schedule actions after a specific date, the scheduler ignores the date and executes synchronously.
public struct ImmediateScheduler : Scheduler {
    
    /// The time type used by the immediate scheduler.
    public struct SchedulerTimeType : Strideable {
        
        /// Returns the distance to another immediate scheduler time; this distance is always `0` in the context of an immediate scheduler.
        ///
        /// - Parameter other: The other scheduler time.
        /// - Returns: `0`, as a `Stride`.
        public func distance(to other: ImmediateScheduler.SchedulerTimeType) -> ImmediateScheduler.SchedulerTimeType.Stride {
            return Stride(0)
        }
        
        /// Advances the time by the specified amount; this is meaningless in the context of an immediate scheduler.
        ///
        /// - Parameter n: The amount to advance by. The `ImmediateScheduler` ignores this value.
        /// - Returns: An empty `SchedulerTimeType`.
        public func advanced(by n: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType {
            return self
        }
        
        /// The increment by which the immediate scheduler counts time.
        public struct Stride : ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {
            
            public typealias FloatLiteralType = Double
            
            public typealias IntegerLiteralType = Int
            
            public typealias Magnitude = Int
            
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
            
            public init?<T>(exactly source: T) where T : BinaryInteger {
                guard let v = Int(exactly: source) else {
                    return nil
                }
                self.magnitude = v
            }
            
            public static func < (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> Bool {
                return lhs.magnitude < rhs.magnitude
            }
            
            public static func * (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(integerLiteral: lhs.magnitude * rhs.magnitude)
            }
            
            public static func + (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(integerLiteral: lhs.magnitude + rhs.magnitude)
            }
            
            public static func - (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(integerLiteral: lhs.magnitude - rhs.magnitude)
            }
            
            public static func -= (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) {
                lhs = lhs - rhs
            }
            
            public static func *= (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) {
                lhs = lhs * rhs
            }
            
            public static func += (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) {
                lhs = lhs + rhs
            }
            
            public static func seconds(_ s: Int) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(0)
            }
            
            public static func seconds(_ s: Double) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(0)
            }
            
            public static func milliseconds(_ ms: Int) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(0)
            }
            
            public static func microseconds(_ us: Int) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(0)
            }
            
            public static func nanoseconds(_ ns: Int) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(0)
            }
            
            public static func == (a: ImmediateScheduler.SchedulerTimeType.Stride, b: ImmediateScheduler.SchedulerTimeType.Stride) -> Bool {
                return a.magnitude == b.magnitude
            }
        }
    }
    
    public typealias SchedulerOptions = Never
    
    /// The shared instance of the immediate scheduler.
    ///
    /// You cannot create instances of the immediate scheduler yourself. Use only the shared instance.
    public static let shared: ImmediateScheduler = ImmediateScheduler()
    
    public func schedule(options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }
    
    public var now: ImmediateScheduler.SchedulerTimeType {
        return SchedulerTimeType()
    }
    
    public var minimumTolerance: ImmediateScheduler.SchedulerTimeType.Stride {
        return ImmediateScheduler.SchedulerTimeType.Stride(0)
    }
    
    public func schedule(after date: ImmediateScheduler.SchedulerTimeType, tolerance: ImmediateScheduler.SchedulerTimeType.Stride, options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }
    
    public func schedule(after date: ImmediateScheduler.SchedulerTimeType, interval: ImmediateScheduler.SchedulerTimeType.Stride, tolerance: ImmediateScheduler.SchedulerTimeType.Stride, options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        action()
        return AnyCancellable { }
    }
}
