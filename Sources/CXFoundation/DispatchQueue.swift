import CombineX
import Dispatch

#if os(Linux)
extension DispatchQueue: CombineXCompatible { }

extension DispatchQueue {
    
    public enum CX { }
}
#endif

public typealias DispatchQueueCXWrapper = DispatchQueue.DispatchQueueCXWrapper

extension CombineXCompatible where Self: DispatchQueue {
    
    public var cx: DispatchQueueCXWrapper {
        return DispatchQueueCXWrapper(self)
    }
    
    public static var cx: DispatchQueueCXWrapper.Type {
        return DispatchQueueCXWrapper.self
    }
}

extension DispatchQueue {
    
    public class DispatchQueueCXWrapper: AnyObjectCXWrapper<DispatchQueue>, CombineX.Scheduler {
        
        /// The scheduler time type used by the dispatch queue.
        public struct SchedulerTimeType : Strideable, Hashable {

            /// The dispatch time represented by this type.
            public var dispatchTime: DispatchTime

            /// Creates a dispatch queue time type instance.
            ///
            /// - Parameter time: The dispatch time to represent.
            public init(_ time: DispatchTime) {
                self.dispatchTime = time
            }

            /// Returns the distance to another dispatch queue time.
            ///
            /// - Parameter other: Another dispatch queue time.
            /// - Returns: The time interval between this time and the provided time.
            public func distance(to other: SchedulerTimeType) -> SchedulerTimeType.Stride {
                return .nanoseconds(Int(other.dispatchTime.uptimeNanoseconds - self.dispatchTime.uptimeNanoseconds))
            }

            /// Returns a dispatch queue scheduler time calculated by advancing this instance’s time by the given interval.
            ///
            /// - Parameter n: A time interval to advance.
            /// - Returns: A dispatch queue time advanced by the given interval from this instance’s time.
            public func advanced(by n: SchedulerTimeType.Stride) -> SchedulerTimeType {
                return .init(self.dispatchTime + n.timeInterval)
            }

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

            /// A type that represents the distance between two values.
            public struct Stride : SchedulerTimeIntervalConvertible, Comparable, SignedNumeric, ExpressibleByFloatLiteral, Hashable, Codable {

                /// If created via floating point literal, the value is converted to nanoseconds via multiplication.
                public typealias FloatLiteralType = Double

                /// Nanoseconds, same as DispatchTimeInterval.
                public typealias IntegerLiteralType = Int

                /// A type that can represent the absolute value of any possible value of the
                /// conforming type.
                public typealias Magnitude = Int

                /// The value of this time interval in nanoseconds.
                public var magnitude: Int
                
                init(magnitude: Int) {
                    self.magnitude = magnitude
                }

                /// A `DispatchTimeInterval` created with the value of this type in nanoseconds.
                public var timeInterval: DispatchTimeInterval {
                    return .nanoseconds(self.magnitude)
                }

                /// Creates a dispatch queue time interval from the given dispatch time interval.
                ///
                /// - Parameter timeInterval: A dispatch time interval.
                public init(_ timeInterval: DispatchTimeInterval) {
                    let now = DispatchTime.now()
                    self.magnitude = Int((now + timeInterval).uptimeNanoseconds - now.uptimeNanoseconds)
                }

                /// Creates a dispatch queue time interval from a floating-point seconds value.
                ///
                /// - Parameter value: The number of seconds, as a `Double`.
                public init(floatLiteral value: Double) {
                    self.magnitude = Int(value * Double(Const.nsec_per_sec))
                }

                /// Creates a dispatch queue time interval from an integer seconds value.
                ///
                /// - Parameter value: The number of seconds, as an `Int`.
                public init(integerLiteral value: Int) {
                    self.magnitude = value * Const.nsec_per_sec
                }

                /// Creates a dispatch queue time interval from a binary integer type.
                ///
                /// If `exactly` cannot convert to an `Int`, the resulting time interval is `nil`.
                /// - Parameter exactly: A binary integer representing a time interval.
                public init?<T>(exactly source: T) where T : BinaryInteger {
                    guard let value = Int(exactly: source) else {
                        return nil
                    }
                    self.init(integerLiteral: value)
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
                    return .init(magnitude: lhs.magnitude * rhs.magnitude)
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
                    return .init(magnitude: lhs.magnitude + rhs.magnitude)
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
                    return .init(magnitude: lhs.magnitude - rhs.magnitude)
                }

                /// Subtracts the second value from the first and stores the difference in the
                /// left-hand-side variable.
                ///
                /// - Parameters:
                ///   - lhs: A numeric value.
                ///   - rhs: The value to subtract from `lhs`.
                public static func -= (lhs: inout SchedulerTimeType.Stride, rhs: SchedulerTimeType.Stride) {
                    lhs = lhs + rhs
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

                public static func seconds(_ s: Double) -> SchedulerTimeType.Stride {
                    return .init(floatLiteral: s)
                }

                public static func seconds(_ s: Int) -> SchedulerTimeType.Stride {
                    return .init(integerLiteral: s)
                }

                public static func milliseconds(_ ms: Int) -> SchedulerTimeType.Stride {
                    return .init(.milliseconds(ms))
                }

                public static func microseconds(_ us: Int) -> SchedulerTimeType.Stride {
                    return .init(.microseconds(us))
                }

                public static func nanoseconds(_ ns: Int) -> SchedulerTimeType.Stride {
                    return .init(.nanoseconds(ns))
                }

                /// The hash value.
                ///
                /// Hash values are not guaranteed to be equal across different executions of
                /// your program. Do not save hash values to use during a future execution.
                ///
                /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
                ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    //            public var hashValue: Int { get }

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
    //            public func hash(into hasher: inout Hasher)

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

                /// Returns a Boolean value indicating whether two values are equal.
                ///
                /// Equality is the inverse of inequality. For any values `a` and `b`,
                /// `a == b` implies that `a != b` is `false`.
                ///
                /// - Parameters:
                ///   - lhs: A value to compare.
                ///   - rhs: Another value to compare.
    //            public static func == (a: SchedulerTimeType.Stride, b: SchedulerTimeType.Stride) -> Bool
            }

            /// The hash value.
            ///
            /// Hash values are not guaranteed to be equal across different executions of
            /// your program. Do not save hash values to use during a future execution.
            ///
            /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
            ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    //        public var hashValue: Int { get }
            
            public func hash(into hasher: inout Hasher) {
                hasher.combine(self.dispatchTime.uptimeNanoseconds)
            }
        }

        /// Options that affect the operation of the dispatch queue scheduler.
        public struct SchedulerOptions {

            /// The dispatch queue quality of service.
            public var qos: DispatchQoS

            /// The dispatch queue work item flags.
            public var flags: DispatchWorkItemFlags

            /// The dispatch group, if any, that should be used for performing actions.
            public var group: DispatchGroup?

            public init(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], group: DispatchGroup? = nil) {
                self.qos = qos
                self.flags = flags
                self.group = group
            }
        }

        /// Returns the minimum tolerance allowed by the scheduler.
        public var minimumTolerance: SchedulerTimeType.Stride {
            return .nanoseconds(0)
        }

        /// Returns this scheduler's definition of the current moment in time.
        public var now: SchedulerTimeType {
            return .init(.now())
        }

        /// Performs the action at the next possible opportunity.
        public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            self.base.async(group: options?.group, qos: options?.qos ?? .unspecified, flags: options?.flags ?? [], execute: action)
        }

        /// Performs the action at some time after the specified date.
        public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            let timer = DispatchSource.makeTimerSource(queue: self.base)
            var ref: DispatchSourceTimer? = timer
            
            timer.setEventHandler() {
                action()
                
                ref?.cancel()
                ref = nil
            }
            
            timer.schedule(deadline: date.dispatchTime, leeway: Swift.max(self.minimumTolerance, tolerance).timeInterval)
            timer.resume()
        }

        /// Performs the action at some time after the specified date, at the specified
        /// frequency, optionally taking into account tolerance if possible.
        public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            let timer = DispatchSource.makeTimerSource(queue: self.base)
            
            timer.setEventHandler() {
                action()
            }
            
            timer.schedule(deadline: date.dispatchTime, repeating: interval.timeInterval, leeway: Swift.max(self.minimumTolerance, tolerance).timeInterval)
            timer.resume()
            
            return AnyCancellable {
                timer.cancel()
            }
        }
    }
    
}
