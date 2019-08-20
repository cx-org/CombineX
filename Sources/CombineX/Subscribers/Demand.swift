extension Subscribers {
    
    /// A requested number of items, sent to a publisher from a subscriber via the subscription.
    ///
    /// - unlimited: A request for an unlimited number of items.
    /// - max: A request for a maximum number of items.
    public struct Demand : Equatable, Comparable, Hashable, Codable, CustomStringConvertible {
        
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
        
        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        public var description: String {
            return self == .unlimited ? "unlimited" : "max(\(self.rawValue))"
        }

        /// When adding any value to .unlimited, the result is .unlimited.
        @inlinable
        public static func + (lhs: Subscribers.Demand, rhs: Subscribers.Demand) -> Subscribers.Demand {
            let (v, overflow) = lhs.rawValue.addingReportingOverflow(rhs.rawValue)
            return overflow ? .unlimited : Demand(v)
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
            return overflow ? .unlimited : Demand(v)
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
                // FIXME: Doc says "any operation that would result in a negative value is clamped to .max(0)", but in Apple's Combine, it will actually crash. See "DemandSpec.swift#2.2" for more information.
                let (v, overflow) = lhs.rawValue.subtractingReportingOverflow(rhs.rawValue)
                return overflow ? .none : Demand(v)
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
        
        /// If lhs is .unlimited, then the result is always false. If rhs is .unlimited then the result is always true. Otherwise, the two max values are compared.
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
        
        /// Returns a Boolean value that indicates whether the value of the first
        /// argument is greater than or equal to that of the second argument.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
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
            return self == .unlimited ? nil : Int(rawValue)
        }
        
        private enum CodingKeys: CodingKey {
            case rawValue
        }
        
        /// Creates a new instance by decoding from the given decoder.
        ///
        /// This initializer throws an error if reading from the decoder fails, or
        /// if the data read is corrupted or otherwise invalid.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(UInt.self)
        }
        
        /// Encodes this value into the given encoder.
        ///
        /// If the value fails to encode anything, `encoder` will encode an empty
        /// keyed container in its place.
        ///
        /// This function throws an error if any values are invalid for the given
        /// encoder's format.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }
        
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
//        public func hash(into hasher: inout Hasher) {
//        }

    }
}
