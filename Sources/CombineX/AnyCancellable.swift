/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
final public class AnyCancellable: Cancellable, Hashable {
    
    private var cancelBody: (() -> Void)?

    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancel: @escaping () -> Void) {
        self.cancelBody = cancel
    }
    
    public init<C>(_ canceller: C) where C: Cancellable {
        self.cancelBody = canceller.cancel
    }
    
    /// Cancel the activity.
    final public func cancel() {
        self.cancelBody?()
        self.cancelBody = nil
    }
    
    deinit {
        self.cancelBody?()
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
    final public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    ///
    /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
    ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}

extension AnyCancellable {
    
    /// Stores this AnyCancellable in the specified collection.
    /// Parameters:
    ///    - collection: The collection to store this AnyCancellable.
    final public func store<C>(in collection: inout C) where C : RangeReplaceableCollection, C.Element == AnyCancellable {
        collection.append(self)
    }
    
    /// Stores this AnyCancellable in the specified set.
    /// Parameters:
    ///    - collection: The set to store this AnyCancellable.
    final public func store(in set: inout Set<AnyCancellable>) {
        set.insert(self)
    }

}

