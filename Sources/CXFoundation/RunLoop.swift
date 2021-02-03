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

// Adapted from the original file:
// https://github.com/apple/swift/blob/main/stdlib/public/Darwin/Foundation/Schedulers%2BRunLoop.swift

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

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
            return Stride(floatLiteral: other.date.timeIntervalSince(date))
        }
    
        /// Returns a run loop scheduler time calculated by advancing this instance’s time by the given interval.
        ///
        /// - Parameter n: A time interval to advance.
        /// - Returns: A dispatch queue time advanced by the given interval from this instance’s time.
        public func advanced(by n: SchedulerTimeType.Stride) -> SchedulerTimeType {
            return SchedulerTimeType(date.addingTimeInterval(n.timeInterval))
        }
        
        /// The interval by which run loop times advance.
        public struct Stride: ExpressibleByFloatLiteral, Comparable, SignedNumeric, Codable, SchedulerTimeIntervalConvertible {
            public typealias FloatLiteralType = TimeInterval
            public typealias IntegerLiteralType = TimeInterval
            public typealias Magnitude = TimeInterval

            /// The value of this time interval in seconds.
            public var magnitude: TimeInterval
            
            /// The value of this time interval in seconds.
            public var timeInterval: TimeInterval {
                return magnitude
            }

            public init(integerLiteral value: TimeInterval) {
                magnitude = value
            }
            
            public init(floatLiteral value: TimeInterval) {
                magnitude = value
            }
            
            public init(_ timeInterval: TimeInterval) {
                magnitude = timeInterval
            }
            
            public init?<T>(exactly source: T) where T: BinaryInteger {
                if let d = TimeInterval(exactly: source) {
                    magnitude = d
                } else {
                    return nil
                }
            }
            
            // ---
            
            public static func < (lhs: Stride, rhs: Stride) -> Bool {
                return lhs.magnitude < rhs.magnitude
            }

            // ---
            
            public static func * (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(lhs.timeInterval * rhs.timeInterval)
            }
            
            public static func + (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(lhs.magnitude + rhs.magnitude)
            }
            
            public static func - (lhs: Stride, rhs: Stride) -> Stride {
                return Stride(lhs.magnitude - rhs.magnitude)
            }

            // ---
            
            public static func *= (lhs: inout Stride, rhs: Stride) {
                let result = lhs * rhs
                lhs = result
            }
            
            public static func += (lhs: inout Stride, rhs: Stride) {
                let result = lhs + rhs
                lhs = result
            }

            public static func -= (lhs: inout Stride, rhs: Stride) {
                let result = lhs - rhs
                lhs = result
            }
            
            // ---
            
            public static func seconds(_ s: Int) -> Stride {
                return Stride(Double(s))
            }
            
            public static func seconds(_ s: Double) -> Stride {
                return Stride(s)
            }
            
            public static func milliseconds(_ ms: Int) -> Stride {
                return Stride(Double(ms) / 1_000.0)
            }
            
            public static func microseconds(_ us: Int) -> Stride {
                return Stride(Double(us) / 1_000_000.0)
            }
            
            public static func nanoseconds(_ ns: Int) -> Stride {
                return Stride(Double(ns) / 1_000_000_000.0)
            }
        }
    }
    
    /// Options that affect the operation of the run loop scheduler.
    public struct SchedulerOptions { }

    public func schedule(options: SchedulerOptions?,
                         _ action: @escaping () -> Void) {
        self.base.cx_perform(action)
    }
    
    public func schedule(after date: SchedulerTimeType,
                         tolerance: SchedulerTimeType.Stride,
                         options: SchedulerOptions?,
                         _ action: @escaping () -> Void) {
        #if canImport(ObjectiveC)
        let ti = date.date.timeIntervalSince(Date())
        self.base.perform(#selector(RunLoop.cx_runLoopScheduled), with: _CXRunLoopAction(action), afterDelay: ti)
        #else
        let timer = Timer.cx_init(fire: date.date, interval: 42, repeats: false) { _ in action() }
        timer.tolerance = tolerance.timeInterval
        self.base.add(timer, forMode: .default)
        #endif
    }
    
    public func schedule(after date: SchedulerTimeType,
                         interval: SchedulerTimeType.Stride,
                         tolerance: SchedulerTimeType.Stride,
                         options: SchedulerOptions?,
                         _ action: @escaping () -> Void) -> Cancellable {
        let timer = Timer.cx_init(fire: date.date, interval: interval.timeInterval, repeats: true) { _ in
            action()
        }

        timer.tolerance = tolerance.timeInterval
        self.base.add(timer, forMode: .default)

        return AnyCancellable(timer.invalidate)
    }

    public var now: SchedulerTimeType {
        return SchedulerTimeType(Date())
    }
        
    public var minimumTolerance: SchedulerTimeType.Stride {
        return 0.0
    }
}

#if canImport(ObjectiveC)

extension RunLoop {
    @objc
    fileprivate func cx_runLoopScheduled(action: _CXRunLoopAction) {
        action.action()
    }
}

@objc
private class _CXRunLoopAction: NSObject {
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
}

#endif
