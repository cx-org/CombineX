import CombineX
import Foundation

public typealias RunLoopCXWrapper = RunLoop.RunLoopCXWrapper

extension CombineXCompatible where Self: RunLoop {
    
    public var cx: RunLoopCXWrapper {
        return RunLoopCXWrapper(self)
    }
    
    public static var cx: RunLoopCXWrapper.Type {
        return RunLoopCXWrapper.self
    }
}

extension RunLoop {
    
    public class RunLoopCXWrapper: AnyObjectCXWrapper<RunLoop>, CombineX.Scheduler {
        
        /// The scheduler time type used by the run loop.
        public struct SchedulerTimeType : Strideable, Codable, Hashable {

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
            public struct Stride : ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {

                /// A type that represents a floating-point literal.
                ///
                /// Valid types for `FloatLiteralType` are `Float`, `Double`, and `Float80`
                /// where available.
                public typealias FloatLiteralType = TimeInterval

                /// A type that represents an integer literal.
                ///
                /// The standard library integer and floating-point types are all valid types
                /// for `IntegerLiteralType`.
                public typealias IntegerLiteralType = TimeInterval

                /// A type that can represent the absolute value of any possible value of the
                /// conforming type.
                public typealias Magnitude = TimeInterval

                /// The value of this time interval in seconds.
                public var magnitude: TimeInterval

                /// The value of this time interval in seconds.
                public var timeInterval: TimeInterval {
                    return self.magnitude
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
                public init(integerLiteral value: TimeInterval) {
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
                public init(floatLiteral value: TimeInterval) {
                    self.magnitude = value
                }

                public init(_ timeInterval: TimeInterval) {
                    self.magnitude = timeInterval
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
                    guard let value = Double(exactly: source) else {
                        return nil
                    }
                    self.init(value)
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
                public static func < (lhs: SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) -> Bool {
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
                public static func * (lhs: SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) -> SchedulerTimeType.Stride {
                    return .init(lhs.magnitude * rhs.magnitude)
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
                public static func + (lhs: SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) -> SchedulerTimeType.Stride {
                    return .init(lhs.magnitude + rhs.magnitude)
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
                public static func - (lhs: SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) -> SchedulerTimeType.Stride {
                    return .init(lhs.magnitude - rhs.magnitude)
                }

                /// Multiplies two values and stores the result in the left-hand-side
                /// variable.
                ///
                /// - Parameters:
                ///   - lhs: The first value to multiply.
                ///   - rhs: The second value to multiply.
                public static func *= (lhs: inout SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) {
                    lhs = lhs * rhs
                }

                /// Adds two values and stores the result in the left-hand-side variable.
                ///
                /// - Parameters:
                ///   - lhs: The first value to add.
                ///   - rhs: The second value to add.
                public static func += (lhs: inout SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) {
                    lhs = lhs + rhs
                }

                /// Subtracts the second value from the first and stores the difference in the
                /// left-hand-side variable.
                ///
                /// - Parameters:
                ///   - lhs: A numeric value.
                ///   - rhs: The value to subtract from `lhs`.
                public static func -= (lhs: inout SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) {
                    lhs = lhs - rhs
                }

                public static func seconds(_ s: Int) -> SchedulerTimeType.Stride {
                    return .init(Double(s))
                }

                public static func seconds(_ s: Double) -> SchedulerTimeType.Stride {
                    return .init(s)
                }

                public static func milliseconds(_ ms: Int) -> SchedulerTimeType.Stride {
                    return .init(Double(ms) / Double(Const.msec_per_sec))
                }

                public static func microseconds(_ us: Int) -> SchedulerTimeType.Stride {
                    return .init(Double(us) / Double(Const.usec_per_sec))
                }

                public static func nanoseconds(_ ns: Int) -> SchedulerTimeType.Stride {
                    return .init(Double(ns) / Double(Const.nsec_per_sec))
                }

                /// Returns a Boolean value indicating whether two values are equal.
                ///
                /// Equality is the inverse of inequality. For any values `a` and `b`,
                /// `a == b` implies that `a != b` is `false`.
                ///
                /// - Parameters:
                ///   - lhs: A value to compare.
                ///   - rhs: Another value to compare.
                public static func == (a: SchedulerTimeType.Stride, b: SchedulerTimeType.Stride) -> Bool {
                    return a.magnitude == b.magnitude
                }

                /// Creates a new instance by decoding from the given decoder.
                ///
                /// This initializer throws an error if reading from the decoder fails, or
                /// if the data read is corrupted or otherwise invalid.
                ///
                /// - Parameter decoder: The decoder to read data from.
    //            public init(from decoder: Decoder) throws

                /// Encodes this value into the given encoder.
                ///
                /// If the value fails to encode anything, `encoder` will encode an empty
                /// keyed container in its place.
                ///
                /// This function throws an error if any values are invalid for the given
                /// encoder's format.
                ///
                /// - Parameter encoder: The encoder to write data to.
    //            public func encode(to encoder: Encoder) throws
            }

            /// Creates a new instance by decoding from the given decoder.
            ///
            /// This initializer throws an error if reading from the decoder fails, or
            /// if the data read is corrupted or otherwise invalid.
            ///
            /// - Parameter decoder: The decoder to read data from.
    //        public init(from decoder: Decoder) throws

            /// Encodes this value into the given encoder.
            ///
            /// If the value fails to encode anything, `encoder` will encode an empty
            /// keyed container in its place.
            ///
            /// This function throws an error if any values are invalid for the given
            /// encoder's format.
            ///
            /// - Parameter encoder: The encoder to write data to.
    //        public func encode(to encoder: Encoder) throws

            /// The hash value.
            ///
            /// Hash values are not guaranteed to be equal across different executions of
            /// your program. Do not save hash values to use during a future execution.
            ///
            /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
            ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    //        public var hashValue: Int { get }

            /// Hashes the essential components of this value by feeding them into the
            /// given hasher.
            ///
            /// Implement this method to conform to the `Hashable` protocol. The
            /// components used for hashing must be the same as the components compared
            /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
            /// with each of these components.
            ///
            /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
            ///   compile-time error in the future.
            ///
            /// - Parameter hasher: The hasher to use when combining the components
            ///   of this instance.
    //        public func hash(into hasher: inout Hasher)
        }
        

        /// Options that affect the operation of the run loop scheduler.
        ///
        /// The run loop doesn’t support any scheduler options.
        public struct SchedulerOptions {
        }
        
        /// Performs the action at the next possible opportunity.
        public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            self.base.cx_perform {
                action()
            }
        }

        /// Performs the action at some time after the specified date.
        public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            Timer.cx_scheduledTimer(withTimeInterval: self.now.distance(to: date).timeInterval, repeats: false) { (_) in
                action()
            }
        }

        /// Performs the action at some time after the specified date, at the specified
        /// frequency, optionally taking into account tolerance if possible.
        public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            let timer = Timer.cx_init(fire: date.date, interval: interval.timeInterval, repeats: true) { _ in
                action()
            }
            self.base.add(timer, forMode: .default)
            return AnyCancellable {
                timer.invalidate()
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
    }
}
