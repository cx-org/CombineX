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
        
        /// Returns the number of requested values, or nil if unlimited.
        @inlinable
        public var max: Int? {
            return self == .unlimited ? nil: Int(rawValue)
        }
        
        @inlinable
        init(_ rawValue: UInt) {
            self.rawValue = min(Demand._unlimited, rawValue)
        }
        
        // MARK: - Static Constructor
        
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
        
        // MARK: Equatable
        
        @inlinable
        public static func == (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        // MARK: Equatable with Int
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func == (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if lhs == .unlimited {
                return false
            }
            return Int(lhs.rawValue) == rhs
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func != (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if lhs == .unlimited {
                return true
            }
            return Int(lhs.rawValue) != rhs
        }
        
        /// Returns `true` if `lhs` and `rhs` are equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func == (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            if rhs == .unlimited {
                return false
            }
            return lhs == Int(rhs.rawValue)
        }
        
        /// Returns `true` if `lhs` and `rhs` are not equal. `.unlimited` is not equal to any integer.
        @inlinable
        public static func != (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            if rhs == .unlimited {
                return true
            }
            return lhs != Int(rhs.rawValue)
        }
        
        // MARK: - Comparable
        
        /// If lhs is .unlimited, then the result is always false. If rhs is .unlimited then the result is always
        /// false. Otherwise, the two max values are compared.
        @inlinable
        public static func < (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, .unlimited):
                return false
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
            switch (lhs, rhs) {
            case (.unlimited, .unlimited):
                return true
            case (.unlimited, _):
                return false
            case (_, .unlimited):
                return true
            default:
                return lhs.rawValue <= rhs.rawValue
            }
        }
        
        /// If both sides are unlimited, the result is always true. If lhs is unlimited, then the result is always true. If rhs is unlimited then the result is always false. Otherwise, this operator compares the demands’ max values.
        @inlinable
        public static func >= (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, .unlimited):
                return true
            case (.unlimited, _):
                return true
            case (_, .unlimited):
                return false
            default:
                return lhs.rawValue >= rhs.rawValue
            }
        }
        
        // FIXME: Combine's doc is wrong, it says "If lhs is .unlimited then the result is always false.".
        /// If rhs is .unlimited, then the result is always false. If lhs is .unlimited then the result is always true. Otherwise, the two max values are compared.
        @inlinable
        public static func > (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Bool {
            switch (lhs, rhs) {
            case (.unlimited, .unlimited):
                return false
            case (.unlimited, _):
                return true
            case (_, .unlimited):
                return false
            default:
                return lhs.rawValue > rhs.rawValue
            }
        }
        
        // MARK: - Comparable with Int
        
        @inlinable
        public static func < (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if lhs == .unlimited {
                return false
            }
            return Int(lhs.rawValue) < rhs
        }
        
        @inlinable
        public static func <= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if lhs == .unlimited {
                return false
            }
            return Int(lhs.rawValue) <= rhs
        }
        
        @inlinable
        public static func >= (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if lhs == .unlimited {
                return true
            }
            return Int(lhs.rawValue) >= rhs
        }
        
        @inlinable
        public static func > (lhs: Subscribers.Demand, rhs: Int) -> Bool {
            if lhs == .unlimited {
                return true
            }
            return Int(lhs.rawValue) > rhs
        }
        
        @inlinable
        public static func < (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            if rhs == .unlimited {
                return true
            }
            return lhs < Int(rhs.rawValue)
        }
        
        @inlinable
        public static func <= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            if rhs == .unlimited {
                return true
            }
            return lhs <= Int(rhs.rawValue)
        }
        
        @inlinable
        public static func >= (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            if rhs == .unlimited {
                return false
            }
            return lhs >= Int(rhs.rawValue)
        }
        
        @inlinable
        public static func > (lhs: Int, rhs: Subscribers.Demand) -> Bool {
            if rhs == .unlimited {
                return false
            }
            return lhs > Int(rhs.rawValue)
        }
        
        // MARK: - AdditiveArithmetic
        
        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func + (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            if lhs == .unlimited || rhs == .unlimited {
                return .unlimited
            }
            let (result, overflow) = Int(lhs.rawValue).addingReportingOverflow(Int(rhs.rawValue))
            return overflow ? .unlimited : .max(result)
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func += (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            if lhs == .unlimited { return }
            lhs = lhs + rhs
        }
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited.
        /// Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand
        /// is not possible; any operation that would result in a negative value is clamped to .max(0).
        @inlinable
        public static func - (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            if lhs == .unlimited {
                return .unlimited
            }
            if rhs == .unlimited {
                return .none
            }
            let (result, overflow) = Int(lhs.rawValue).subtractingReportingOverflow(Int(rhs.rawValue))
            return (overflow || result<0) ? .none : .max(result)
        }
        
        /// When subtracting any value (including .unlimited) from .unlimited, the result is still .unlimited.
        /// Subtracting unlimited from any value (except unlimited) results in .max(0). A negative demand
        /// is not possible; any operation that would result in a negative value is clamped to .max(0).
        @inlinable
        public static func -= (lhs: inout Subscribers.Demand, rhs: Subscribers.Demand) {
            if lhs == .unlimited { return }
            lhs = lhs - rhs
        }
        
        // MARK: - Numeric with Int
        
        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func + (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            if lhs == .unlimited {
                return .unlimited
            }
            let (result, overflow) = Int(lhs.rawValue).addingReportingOverflow(rhs)
            // FIXME: result could be negative and crash
            return overflow ? .unlimited : .max(result)
        }
        
        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func += (lhs: inout Subscribers.Demand, rhs: Int) {
            lhs = lhs + rhs
        }
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is
        /// not possible; any operation that would result in a negative value is clamped to .max(0)
        @inlinable
        public static func - (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            if lhs == .unlimited {
                return .unlimited
            }
            let (result, overflow) = Int(lhs.rawValue).subtractingReportingOverflow(rhs)
            return overflow ? .none : .max(result)
        }
        
        /// When subtracting any value from .unlimited, the result is still .unlimited. A negative demand is
        /// possible, but be aware that it is not usable when requesting values in a subscription.
        @inlinable
        public static func -= (lhs: inout Subscribers.Demand, rhs: Int) {
            if lhs == .unlimited { return }
            lhs = lhs - rhs
        }
        
        // TODO: not @inlinable 🤔
        public static func * (lhs: Subscribers.Demand, rhs: Int) -> Subscribers.Demand {
            if lhs == .unlimited { return .unlimited }
            precondition(rhs >= 0)
            let (result, overflow) = lhs.rawValue.multipliedReportingOverflow(by: UInt(rhs))
            return overflow ? .unlimited : Demand(result)
        }
        
        @inlinable
        public static func *= (lhs: inout Subscribers.Demand, rhs: Int) {
            if lhs == .unlimited { return }
            lhs = lhs * rhs
        }
        
        // MARK: - CustomStringConvertible
        
        public var description: String {
            return self == .unlimited ? "unlimited" : "max(\(self.rawValue))"
        }
        
        // MARK: - Codable
        
        private enum CodingKeys: CodingKey {
            case rawValue
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(UInt.self)
            self.init(rawValue)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }
    }
}
