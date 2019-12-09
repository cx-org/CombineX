/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
/// An AnyCancellable instance automatically calls `cancel()` when deinitialized.
public final class AnyCancellable: Cancellable, Hashable {
    
    private var cancelBody: (() -> Void)?

    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancel: @escaping () -> Void) {
        self.cancelBody = cancel
    }
    
    public init<C: Cancellable>(_ canceller: C) {
        self.cancelBody = canceller.cancel
    }
    
    public final func cancel() {
        self.cancelBody?()
        self.cancelBody = nil
    }
    
    deinit {
        self.cancelBody?()
    }
    
    public final func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        return lhs === rhs
    }
}

extension AnyCancellable {
    
    /// Stores this AnyCancellable in the specified collection.
    /// Parameters:
    ///    - collection: The collection to store this AnyCancellable.
    public final func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == AnyCancellable {
        collection.append(self)
    }
    
    /// Stores this AnyCancellable in the specified set.
    /// Parameters:
    ///    - collection: The set to store this AnyCancellable.
    public final func store(in set: inout Set<AnyCancellable>) {
        set.insert(self)
    }
}
