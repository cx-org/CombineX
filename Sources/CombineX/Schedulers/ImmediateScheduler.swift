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
            
            /// A type that represents a floating-point literal.
            ///
            /// Valid types for `FloatLiteralType` are `Float`, `Double`, and `Float80`
            /// where available.
            public typealias FloatLiteralType = Double
            
            /// A type that represents an integer literal.
            ///
            /// The standard library integer and floating-point types are all valid types
            /// for `IntegerLiteralType`.
            public typealias IntegerLiteralType = Int
            
            /// A type that can represent the absolute value of any possible value of the
            /// conforming type.
            public typealias Magnitude = Int
            
            /// The magnitude of this value.
            ///
            /// For any numeric value `x`, `x.magnitude` is the absolute value of `x`.
            /// You can use the `magnitude` property in operations that are simpler to
            /// implement in terms of unsigned values, such as printing the value of an
            /// integer, which is just printing a '-' character in front of an absolute
            /// value.
            ///
            ///     let x = -200
            ///     // x.magnitude == 200
            ///
            /// The global `abs(_:)` function provides more familiar syntax when you need
            /// to find an absolute value. In addition, because `abs(_:)` always returns
            /// a value of the same type, even in a generic context, using the function
            /// instead of the `magnitude` property is encouraged.
            public var magnitude: Int

            public init(_ value: Int) {
                self.magnitude = value
            }
            
            /// Creates an instance initialized to the specified integer value.
            ///
            /// Do not call this initializer directly. Instead, initialize a variable or
            /// constant using an integer literal. For example:
            ///
            ///     let x = 23
            ///
            /// In this example, the assignment to the `x` constant calls this integer
            /// literal initializer behind the scenes.
            ///
            /// - Parameter value: The value to create.
            public init(integerLiteral value: Int) {
                self.magnitude = value
            }
            
            /// Creates an instance initialized to the specified floating-point value.
            ///
            /// Do not call this initializer directly. Instead, initialize a variable or
            /// constant using a floating-point literal. For example:
            ///
            ///     let x = 21.5
            ///
            /// In this example, the assignment to the `x` constant calls this
            /// floating-point literal initializer behind the scenes.
            ///
            /// - Parameter value: The value to create.
            public init(floatLiteral value: Double) {
                self.magnitude = Int(value)
            }
            
            /// Creates a new instance from the given integer, if it can be represented
            /// exactly.
            ///
            /// If the value passed as `source` is not representable exactly, the result
            /// is `nil`. In the following example, the constant `x` is successfully
            /// created from a value of `100`, while the attempt to initialize the
            /// constant `y` from `1_000` fails because the `Int8` type can represent
            /// `127` at maximum:
            ///
            ///     let x = Int8(exactly: 100)
            ///     // x == Optional(100)
            ///     let y = Int8(exactly: 1_000)
            ///     // y == nil
            ///
            /// - Parameter source: A value to convert to this type.
            public init?<T>(exactly source: T) where T : BinaryInteger {
                guard let v = Int(exactly: source) else {
                    return nil
                }
                self.magnitude = v
            }
            
            /// Returns a Boolean value indicating whether the value of the first
            /// argument is less than that of the second argument.
            ///
            /// This function is the only requirement of the `Comparable` protocol. The
            /// remainder of the relational operator functions are implemented by the
            /// standard library for any type that conforms to `Comparable`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func < (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> Bool {
                return lhs.magnitude < rhs.magnitude
            }
            
            /// Multiplies two values and produces their product.
            ///
            /// The multiplication operator (`*`) calculates the product of its two
            /// arguments. For example:
            ///
            ///     2 * 3                   // 6
            ///     100 * 21                // 2100
            ///     -10 * 15                // -150
            ///     3.5 * 2.25              // 7.875
            ///
            /// You cannot use `*` with arguments of different types. To multiply values
            /// of different types, convert one of the values to the other value's type.
            ///
            ///     let x: Int8 = 21
            ///     let y: Int = 1000000
            ///     Int(x) * y              // 21000000
            ///
            /// - Parameters:
            ///   - lhs: The first value to multiply.
            ///   - rhs: The second value to multiply.
            public static func * (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(integerLiteral: lhs.magnitude * rhs.magnitude)
            }
            
            /// Adds two values and produces their sum.
            ///
            /// The addition operator (`+`) calculates the sum of its two arguments. For
            /// example:
            ///
            ///     1 + 2                   // 3
            ///     -10 + 15                // 5
            ///     -15 + -5                // -20
            ///     21.5 + 3.25             // 24.75
            ///
            /// You cannot use `+` with arguments of different types. To add values of
            /// different types, convert one of the values to the other value's type.
            ///
            ///     let x: Int8 = 21
            ///     let y: Int = 1000000
            ///     Int(x) + y              // 1000021
            ///
            /// - Parameters:
            ///   - lhs: The first value to add.
            ///   - rhs: The second value to add.
            public static func + (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(integerLiteral: lhs.magnitude + rhs.magnitude)
            }
            
            /// Subtracts one value from another and produces their difference.
            ///
            /// The subtraction operator (`-`) calculates the difference of its two
            /// arguments. For example:
            ///
            ///     8 - 3                   // 5
            ///     -10 - 5                 // -15
            ///     100 - -5                // 105
            ///     10.5 - 100.0            // -89.5
            ///
            /// You cannot use `-` with arguments of different types. To subtract values
            /// of different types, convert one of the values to the other value's type.
            ///
            ///     let x: UInt8 = 21
            ///     let y: UInt = 1000000
            ///     y - UInt(x)             // 999979
            ///
            /// - Parameters:
            ///   - lhs: A numeric value.
            ///   - rhs: The value to subtract from `lhs`.
            public static func - (lhs: ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) -> ImmediateScheduler.SchedulerTimeType.Stride {
                return Stride(integerLiteral: lhs.magnitude - rhs.magnitude)
            }
            
            /// Subtracts the second value from the first and stores the difference in the
            /// left-hand-side variable.
            ///
            /// - Parameters:
            ///   - lhs: A numeric value.
            ///   - rhs: The value to subtract from `lhs`.
            public static func -= (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) {
                lhs = lhs - rhs
            }
            
            /// Multiplies two values and stores the result in the left-hand-side
            /// variable.
            ///
            /// - Parameters:
            ///   - lhs: The first value to multiply.
            ///   - rhs: The second value to multiply.
            public static func *= (lhs: inout ImmediateScheduler.SchedulerTimeType.Stride, rhs: ImmediateScheduler.SchedulerTimeType.Stride) {
                lhs = lhs * rhs
            }
            
            /// Adds two values and stores the result in the left-hand-side variable.
            ///
            /// - Parameters:
            ///   - lhs: The first value to add.
            ///   - rhs: The second value to add.
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
            
            /// Returns a Boolean value indicating whether two values are equal.
            ///
            /// Equality is the inverse of inequality. For any values `a` and `b`,
            /// `a == b` implies that `a != b` is `false`.
            ///
            /// - Parameters:
            ///   - lhs: A value to compare.
            ///   - rhs: Another value to compare.
            public static func == (a: ImmediateScheduler.SchedulerTimeType.Stride, b: ImmediateScheduler.SchedulerTimeType.Stride) -> Bool {
                return a.magnitude == b.magnitude
            }
        }
    }
    
    /// A type that defines options accepted by the scheduler.
    ///
    /// This type is freely definable by each `Scheduler`. Typically, operations that take a `Scheduler` parameter will also take `SchedulerOptions`.
    public typealias SchedulerOptions = Never
    
    /// The shared instance of the immediate scheduler.
    ///
    /// You cannot create instances of the immediate scheduler yourself. Use only the shared instance.
    public static let shared: ImmediateScheduler = ImmediateScheduler()
    
    /// Performs the action at the next possible opportunity.
    public func schedule(options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }
    
    /// Returns this scheduler's definition of the current moment in time.
    public var now: ImmediateScheduler.SchedulerTimeType {
        return SchedulerTimeType()
    }
    
    /// Returns the minimum tolerance allowed by the scheduler.
    public var minimumTolerance: ImmediateScheduler.SchedulerTimeType.Stride {
        return ImmediateScheduler.SchedulerTimeType.Stride(0)
    }
    
    /// Performs the action at some time after the specified date.
    public func schedule(after date: ImmediateScheduler.SchedulerTimeType, tolerance: ImmediateScheduler.SchedulerTimeType.Stride, options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void) {
        action()
    }
    
    /// Performs the action at some time after the specified date, at the specified
    /// frequency, optionally taking into account tolerance if possible.
    public func schedule(after date: ImmediateScheduler.SchedulerTimeType, interval: ImmediateScheduler.SchedulerTimeType.Stride, tolerance: ImmediateScheduler.SchedulerTimeType.Stride, options: ImmediateScheduler.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        action()
        return AnyCancellable { }
    }
}
