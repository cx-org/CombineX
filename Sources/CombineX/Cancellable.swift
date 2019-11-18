/// A protocol indicating that an activity or action may be canceled.
///
/// Calling `cancel()` frees up any allocated resources. It also stops side effects such as timers, network access, or disk I/O.
public protocol Cancellable {
    
    /// Cancel the activity.
    func cancel()
}

extension Cancellable {

    /// Stores this Cancellable in the specified collection.
    /// Parameters:
    ///    - collection: The collection to store this Cancellable.
    public func store<C: RangeReplaceableCollection>(in collection: inout C) where C.Element == AnyCancellable {
        collection.append(AnyCancellable(self))
    }

    /// Stores this Cancellable in the specified set.
    /// Parameters:
    ///    - collection: The set to store this Cancellable.
    public func store(in set: inout Set<AnyCancellable>) {
        set.insert(AnyCancellable(self))
    }
}
