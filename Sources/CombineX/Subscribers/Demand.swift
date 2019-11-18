extension Subscribers {
    
    /// A requested number of items, sent to a publisher from a subscriber via the subscription.
    ///
    /// - unlimited: A request for an unlimited number of items.
    /// - max: A request for a maximum number of items.
    public struct Demand: Equatable, Comparable, Hashable, Codable, CustomStringConvertible {
        
        @usableFromInline
        let rawValue: UInt
        
        @usableFromInline
        static let _unlimited = UInt(Int.max) + 1
        
        @inlinable
        init(_ rawValue: UInt) {
            if rawValue > Demand._unlimited {
                self.rawValue = Demand._unlimited
                return
            }
            self.rawValue = rawValue
        }
        
        /// Requests as many values as the `Publisher` can produce.
        public static let unlimited = Demand(Demand._unlimited)
        
        /// A demand for no items.
        ///
        /// This is equivalent to `Demand.max(0)`.
        public static let none = Demand(0)
        
        /// Limits the maximum number of values.
        /// The `Publisher` may send fewer than the requested number.
        /// Negative values will result in a `fatalError`.
        @inlinable
        public static func max(_ value: Int) -> Subscribers.Demand {
            precondition(value >= 0)
            return Demand(UInt(value))
        }
        
        public var description: String {
            return self == .unlimited ? "unlimited" : "max(\(self.rawValue))"
        }

        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func + (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            let (v, overflow) = lhs.rawValue.addingReportingOverflow(rhs.rawValue)
            return overflow ? .unlimited: Demand(v)
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func += (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            lhs = lhs + rhs
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func + (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            if rhs < 0 {
                return lhs - .max(-rhs)
            }
            return lhs + .max(rhs)
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func += (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs + rhs
        }
        
        @inlinable
        public static func * (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            precondition(rhs >= 0)
            let (v, overflow) = lhs.rawValue.multipliedReportingOverflow(by: UInt(rhs))
            return overflow ? .unlimited: Demand(v)
        }
        
        @inlinable
        public static func *= (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs * rhs
        }
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0).
        @inlinable
        public static func - (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            switch (lhs, rhs) {
            case (.unlimited, _):
                return .unlimited
            case (_, .unlimited):
                return .max(0)
            default:
                let (v, overflow) = lhs.rawValue.subtractingReportingOverflow(rhs.rawValue)
                return overflow ? .none: Demand(v)
            }
        }
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited. Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0).
        @inlinable
        public static func -= (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            lhs = lhs - rhs
        }
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is not possible; any operation that would result in a negative value is clamped to .max(0)
        @inlinable
        public static func - (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            return lhs + (-rhs)
        }
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is possible, but be aware that it is not usable when requesting values in a subscription.
        @inlinable
        public static func -= (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs - rhs
        }
        
        @inlinable
        public static func > (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if rhs < 0 {
                return true
            }
            return lhs > .max(rhs)
        }
        
        @inlinable
        public static func >= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return (lhs > rhs) || (lhs == rhs)
        }
        
        @inlinable
        public static func > (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs <= lhs
        }
        
        @inlinable
        public static func >= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return (lhs > rhs) || (lhs == rhs)
        }
        
        @inlinable
        public static func < (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if rhs < 0 {
                return false
            }
            return lhs < .max(rhs)
        }
        
        @inlinable
        public static func < (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs >= lhs
        }
        
        @inlinable
        public static func <= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return (lhs < rhs) || (lhs == rhs)
        }
        
        @inlinable
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
        @inlinable
        public static func == (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        /// If lhs is .unlimited, then the result is always false. If rhs is .unlimited then the result is always false. Otherwise, the two max values are compared.
        @inlinable
        public static func < (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, _):
                return false
            case (_, .unlimited):
                return true
            default:
                return lhs.rawValue < rhs.rawValue
            }
        }
        
        /// If lhs is .unlimited and rhs is .unlimited then the result is true. Otherwise, the rules for < are followed.
        @inlinable
        public static func <= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return (lhs < rhs) || (lhs == rhs)
        }
        
        /// If both sides are unlimited, the result is always true. If lhs is unlimited, then the result is always true. If rhs is unlimited then the result is always false. Otherwise, this operator compares the demands’ max values.
        @inlinable
        public static func >= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return (lhs > rhs) || (lhs == rhs)
        }
        
        // FIXME: Combine's doc is wrong, it says "If lhs is .unlimited then the result is always false.".
        /// If rhs is .unlimited, then the result is always false. If lhs is .unlimited then the result is always true. Otherwise, the two max values are compared.
        @inlinable
        public static func > (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case (_, .unlimited):
                return false
            case (.unlimited, _):
                return true
            default:
                return lhs.rawValue > rhs.rawValue
            }
        }
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func == (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return lhs == .max(rhs)
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func != (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            return !(lhs == rhs)
        }
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func == (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs == lhs
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func != (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            return rhs != lhs
        }
        
        /// Returns the number of requested values, or nil if unlimited.
        @inlinable
        public var max: Int? {
            return self == .unlimited ? nil: Int(rawValue)
        }
        
        private enum CodingKeys: CodingKey {
            case rawValue
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(UInt.self)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }
    }
}
