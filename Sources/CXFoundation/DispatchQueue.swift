import CombineX
import Dispatch

#if !COCOAPODS
import CXNamespace
import CXUtility
#endif

extension CXWrappers {
    
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
    public final class DispatchQueue: NSObject<Dispatch.DispatchQueue> {}
    
    #else
    
    public final class DispatchQueue: CXWrapper {
        
        public typealias Base = Dispatch.DispatchQueue
        
        public let base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
    }
    
    #endif
}

extension DispatchQueue {
    
    public typealias CX = CXWrappers.DispatchQueue
    
    public var cx: CXWrappers.DispatchQueue {
        return CXWrappers.DispatchQueue(wrapping: self)
    }
}
    
extension CXWrappers.DispatchQueue: CombineX.Scheduler {
    
    /// The scheduler time type used by the dispatch queue.
    public struct SchedulerTimeType: Strideable, Hashable {
        
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
        
        public struct Stride: SchedulerTimeIntervalConvertible, Comparable, SignedNumeric, ExpressibleByFloatLiteral, Hashable, Codable {
            
            /// If created via floating point literal, the value is converted to nanoseconds via multiplication.
            public typealias FloatLiteralType = Double
            
            /// Nanoseconds, same as DispatchTimeInterval.
            public typealias IntegerLiteralType = Int
            
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
                switch timeInterval {
                case let .seconds(n):
                    self.magnitude = n.multipliedClamping(by: Const.nsec_per_sec)
                case let .milliseconds(n):
                    self.magnitude = n.multipliedClamping(by: Const.nsec_per_msec)
                case let .microseconds(n):
                    self.magnitude = n.multipliedClamping(by: Const.nsec_per_usec)
                case let .nanoseconds(n):
                    self.magnitude = n
                case .never:
                    self.magnitude = .max
                @unknown default:
                    let now = DispatchTime.now()
                    self.magnitude = Int((now + timeInterval).uptimeNanoseconds - now.uptimeNanoseconds)
                }
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
                self.init(.seconds(value))
            }
            
            /// Creates a dispatch queue time interval from a binary integer type.
            ///
            /// If `exactly` cannot convert to an `Int`, the resulting time interval is `nil`.
            /// - Parameter exactly: A binary integer representing a time interval.
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
                return .init(magnitude: lhs.magnitude + rhs.magnitude)
            }
            
            public static func += (lhs: inout Stride, rhs: Stride) {
                lhs.magnitude += rhs.magnitude
            }
            
            public static func - (lhs: Stride, rhs: Stride) -> Stride {
                return .init(magnitude: lhs.magnitude - rhs.magnitude)
            }
            
            public static func -= (lhs: inout Stride, rhs: Stride) {
                lhs.magnitude -= rhs.magnitude
            }
            
            public static func * (lhs: Stride, rhs: Stride) -> Stride {
                return .init(magnitude: lhs.magnitude * rhs.magnitude)
            }
            
            public static func *= (lhs: inout Stride, rhs: Stride) {
                lhs.magnitude *= rhs.magnitude
            }
            
            public static func seconds(_ s: Double) -> Stride {
                return .init(floatLiteral: s)
            }

            public static func seconds(_ s: Int) -> Stride {
                return .init(integerLiteral: s)
            }

            public static func milliseconds(_ ms: Int) -> Stride {
                return .init(.milliseconds(ms))
            }

            public static func microseconds(_ us: Int) -> Stride {
                return .init(.microseconds(us))
            }

            public static func nanoseconds(_ ns: Int) -> Stride {
                return .init(.nanoseconds(ns))
            }
        }
        
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
    
    public var minimumTolerance: SchedulerTimeType.Stride {
        return .nanoseconds(0)
    }
    
    public var now: SchedulerTimeType {
        return .init(.now())
    }
    
    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.base.async(group: options?.group,
                        qos: options?.qos ?? .unspecified,
                        flags: options?.flags ?? [],
                        execute: action)
    }
    
    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        self.base.asyncAfter(deadline: date.dispatchTime,
                             qos: options?.qos ?? .unspecified,
                             flags: options?.flags ?? [],
                             execute: action)
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        let timer = DispatchSource.makeTimerSource(queue: self.base)
        timer.setEventHandler(qos: options?.qos ?? .unspecified,
                              flags: options?.flags ?? [],
                              handler: action)
        timer.schedule(deadline: date.dispatchTime,
                       repeating: interval.timeInterval,
                       leeway: Swift.max(self.minimumTolerance, tolerance).timeInterval)
        timer.resume()
        return AnyCancellable(timer.cancel)
    }
}
