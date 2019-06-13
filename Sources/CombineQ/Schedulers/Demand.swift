import Foundation

extension Subscribers {
    
    /// A requested number of items, sent to a publisher from a subscriber via the subscription.
    ///
    /// - unlimited: A request for an unlimited number of items.
    /// - max: A request for a maximum number of items.
    public enum Demand : Equatable, Comparable {
        
        /// Requests as many values as the `Publisher` can produce.
        case unlimited
        
        /// Limits the maximum number of values.
        /// The `Publisher` may send fewer than the requested number.
        /// Negative values will result in a `fatalError`.
        case max(Int)
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func + (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            switch (lhs, rhs) {
            case (.max(let d0), .max(let d1)):
                return .max(d0 + d1)
            default:
                return .unlimited
            }
        }
        
        /// A demand for no items.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static var none: Subscribers.Demand {
            return .max(0)
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func += (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            lhs = lhs + rhs
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func + (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            return lhs + .max(rhs)
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        public static func += (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs + rhs
        }
        
        public static func * (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            switch lhs {
            case .max(let d):
                return .max(d * rhs)
            case .unlimited:
                return .unlimited
            }
        }
        
        public static func *= (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs * rhs
        }
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func - (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            switch (lhs, rhs) {
            case (.unlimited, _):
                return .unlimited
            case (.max, .unlimited):
                return .max(0)
            case (.max(let d0), .max(let d1)):
                return .max(d0 - d1)
            }
        }
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func -= (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            lhs = lhs - rhs
        }
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func - (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            return lhs - .max(rhs)
        }
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        public static func -= (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs - rhs
        }
        
        public static func > (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            switch lhs {
            case .max(let d):
                return d > rhs
            case .unlimited:
                return true
            }
        }
        
        public static func >= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return (lhs > rhs) || (lhs == rhs)
        }
        
        public static func > (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs <= lhs
        }
        
        public static func >= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return (lhs > rhs) || (lhs == rhs)
        }
        
        public static func < (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            switch lhs {
            case .max(let d):
                return d < rhs
            case .unlimited:
                return false
            }
        }
        
        public static func < (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs >= lhs
        }
        
        public static func <= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return (lhs < rhs) || (lhs == rhs)
        }
        
        public static func <= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return (lhs < rhs) || (lhs == rhs)
        }
        
        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, unlimited):
                return true
            case (.max(let d0), .max(let d1)):
                return d0 == d1
            default:
                return false
            }
        }
        
        /// If lhs is .unlimited, then the result is always false. If rhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        public static func < (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, _):
                return false
            case (_, .unlimited):
                return false
            case (.max(let d0), .max(let d1)):
                return d0 < d1
            }
        }
        
        /// If lhs is .unlimited and rhs is .unlimited then the result is true. Otherwise, the rules for < are followed.
        public static func <= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return (lhs < rhs) || (lhs == rhs)
        }
        
        /// Returns a Boolean value that indicates whether the value of the first
        /// argument is greater than or equal to that of the second argument.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func >= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return rhs < lhs
        }
        
        /// If rhs is .unlimited, then the result is always false. If lhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        public static func > (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return rhs <= lhs
        }
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            switch lhs {
            case .max(let d):
                return d == rhs
            case .unlimited:
                return false
            }
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return !(lhs == rhs)
        }
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        public static func == (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs == lhs
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        public static func != (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs != lhs
        }
        
        /// Returns the number of requested values, or nil if unlimited.
        public var max: Int? {
            switch self {
            case .max(let d):
                return d
            case .unlimited:
                return nil
            }
        }
    }
}
