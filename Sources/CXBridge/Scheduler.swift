#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Scheduler {
    
    public typealias CX = CXWrappers.AnyScheduler<Self>
    
    public var cx: CX {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CXWrappers {
    
    public struct AnyScheduler<BaseScheduler: Combine.Scheduler>: CXWrapper, CombineX.Scheduler {
        
        public var base: BaseScheduler
        
        public init(wrapping base: BaseScheduler) {
            self.base = base
        }
        
        public var now: SchedulerTimeType {
            return .init(wrapping: base.now)
        }
        
        public var minimumTolerance: SchedulerTimeType.Stride {
            return .init(wrapping: base.minimumTolerance)
        }
        
        public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            base.schedule(options: options?.base, action)
        }
        
        public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            base.schedule(after: date.base, tolerance: tolerance.base, options: options?.base, action)
        }
        
        public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> CombineX.Cancellable {
            return base.schedule(after: date.base, interval: interval.base, tolerance: tolerance.base, options: options?.base, action).cx
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CXWrappers.AnyScheduler {
    
    public struct SchedulerTimeType: CXWrapper, Strideable {
        
        public typealias BaseSchedulerTimeType = BaseScheduler.SchedulerTimeType
        
        public var base: BaseSchedulerTimeType
        
        public init(wrapping base: BaseSchedulerTimeType) {
            self.base = base
        }
        
        public func distance(to other: SchedulerTimeType) -> Stride {
            return .init(wrapping: base.distance(to: other.base))
        }
        
        public func advanced(by n: Stride) -> SchedulerTimeType {
            return .init(wrapping: base.advanced(by: n.base))
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CXWrappers.AnyScheduler.SchedulerTimeType {
    
    public struct Stride: CXWrapper, Comparable, SignedNumeric, CombineX.SchedulerTimeIntervalConvertible {
        
        public typealias BaseStride = BaseSchedulerTimeType.Stride
        
        public var base: BaseStride
        
        public init(wrapping base: BaseStride) {
            self.base = base
        }
        
        public init(integerLiteral value: BaseStride.IntegerLiteralType) {
            self.init(wrapping: .init(integerLiteral: value))
        }
        
        public init?<T>(exactly source: T) where T : BinaryInteger {
            guard let base = BaseStride.init(exactly: source) else {
                return nil
            }
            self.init(wrapping: base)
        }
        
        public var magnitude: BaseStride.Magnitude {
            return base.magnitude
        }
        
        public static func < (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base < rhs.base
        }
        
        public static func <= (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base <= rhs.base
        }
        
        public static func > (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base > rhs.base
        }
        
        public static func >= (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base >= rhs.base
        }
        
        public static func + (lhs: Stride, rhs: Stride) -> Stride {
            return .init(wrapping: lhs.base + rhs.base)
        }
        
        public static func += (lhs: inout Stride, rhs: Stride) {
            lhs.base += rhs.base
        }
        
        public static func - (lhs: Stride, rhs: Stride) -> Stride {
            return .init(wrapping: lhs.base - rhs.base)
        }
        
        public static func -= (lhs: inout Stride, rhs: Stride) {
            lhs.base -= rhs.base
        }
        
        public static func * (lhs: Stride, rhs: Stride) -> Stride {
            return .init(wrapping: lhs.base * rhs.base)
        }
        
        public static func *= (lhs: inout Stride, rhs: Stride) {
            lhs.base *= rhs.base
        }
        
        public static func seconds(_ s: Int) -> Stride {
            return .init(wrapping: .seconds(s))
        }
        
        public static func seconds(_ s: Double) -> Stride {
            return .init(wrapping: .seconds(s))
        }
        
        public static func milliseconds(_ ms: Int) -> Stride {
            return .init(wrapping: .milliseconds(ms))
        }
        
        public static func microseconds(_ us: Int) -> Stride {
            return .init(wrapping: .microseconds(us))
        }
        
        public static func nanoseconds(_ ns: Int) -> Stride {
            return .init(wrapping: .nanoseconds(ns))
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CXWrappers.AnyScheduler {
    
    public struct SchedulerOptions: CXWrapper {
        
        public typealias BaseSchedulerOptions = BaseScheduler.SchedulerOptions
        
        public var base: BaseSchedulerOptions
        
        public init(wrapping base: BaseSchedulerOptions) {
            self.base = base
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.Scheduler {
    
    public typealias AC = ACWrappers.AnyScheduler<Self>
    
    public var ac: AC {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ACWrappers {
    
    public struct AnyScheduler<BaseScheduler: CombineX.Scheduler>: ACWrapper, Combine.Scheduler {
        
        public var base: BaseScheduler
        
        public init(wrapping base: BaseScheduler) {
            self.base = base
        }
        
        public var now: SchedulerTimeType {
            return .init(wrapping: base.now)
        }
        
        public var minimumTolerance: SchedulerTimeType.Stride {
            return .init(wrapping: base.minimumTolerance)
        }
        
        public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            base.schedule(options: options?.base, action)
        }
        
        public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            base.schedule(after: date.base, tolerance: tolerance.base, options: options?.base, action)
        }
        
        public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Combine.Cancellable {
            return base.schedule(after: date.base, interval: interval.base, tolerance: tolerance.base, options: options?.base, action).ac
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ACWrappers.AnyScheduler {
    
    public struct SchedulerTimeType: ACWrapper, Strideable {
        
        public typealias BaseSchedulerTimeType = BaseScheduler.SchedulerTimeType
        
        public var base: BaseSchedulerTimeType
        
        public init(wrapping base: BaseSchedulerTimeType) {
            self.base = base
        }
        
        public func distance(to other: SchedulerTimeType) -> Stride {
            return .init(wrapping: base.distance(to: other.base))
        }
        
        public func advanced(by n: Stride) -> SchedulerTimeType {
            return .init(wrapping: base.advanced(by: n.base))
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ACWrappers.AnyScheduler.SchedulerTimeType {
    
    public struct Stride: ACWrapper, Comparable, SignedNumeric, Combine.SchedulerTimeIntervalConvertible {
        
        public typealias BaseStride = BaseSchedulerTimeType.Stride
        
        public var base: BaseStride
        
        public init(wrapping base: BaseStride) {
            self.base = base
        }
        
        public init(integerLiteral value: BaseStride.IntegerLiteralType) {
            self.init(wrapping: .init(integerLiteral: value))
        }
        
        public init?<T>(exactly source: T) where T : BinaryInteger {
            guard let base = BaseStride.init(exactly: source) else {
                return nil
            }
            self.init(wrapping: base)
        }
        
        public var magnitude: BaseStride.Magnitude {
            return base.magnitude
        }
        
        public static func < (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base < rhs.base
        }
        
        public static func <= (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base <= rhs.base
        }
        
        public static func > (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base > rhs.base
        }
        
        public static func >= (lhs: Stride, rhs: Stride) -> Bool {
            return lhs.base >= rhs.base
        }
        
        public static func + (lhs: Stride, rhs: Stride) -> Stride {
            return .init(wrapping: lhs.base + rhs.base)
        }
        
        public static func += (lhs: inout Stride, rhs: Stride) {
            lhs.base += rhs.base
        }
        
        public static func - (lhs: Stride, rhs: Stride) -> Stride {
            return .init(wrapping: lhs.base - rhs.base)
        }
        
        public static func -= (lhs: inout Stride, rhs: Stride) {
            lhs.base -= rhs.base
        }
        
        public static func * (lhs: Stride, rhs: Stride) -> Stride {
            return .init(wrapping: lhs.base * rhs.base)
        }
        
        public static func *= (lhs: inout Stride, rhs: Stride) {
            lhs.base *= rhs.base
        }
        
        public static func seconds(_ s: Int) -> Stride {
            return .init(wrapping: .seconds(s))
        }
        
        public static func seconds(_ s: Double) -> Stride {
            return .init(wrapping: .seconds(s))
        }
        
        public static func milliseconds(_ ms: Int) -> Stride {
            return .init(wrapping: .milliseconds(ms))
        }
        
        public static func microseconds(_ us: Int) -> Stride {
            return .init(wrapping: .microseconds(us))
        }
        
        public static func nanoseconds(_ ns: Int) -> Stride {
            return .init(wrapping: .nanoseconds(ns))
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ACWrappers.AnyScheduler {
    
    public struct SchedulerOptions: ACWrapper {
        
        public typealias BaseSchedulerOptions = BaseScheduler.SchedulerOptions
        
        public var base: BaseSchedulerOptions
        
        public init(wrapping base: BaseSchedulerOptions) {
            self.base = base
        }
    }
}

// MARK: - To Combine

#endif
