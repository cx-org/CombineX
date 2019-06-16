/// A publisher that provides an explicit means of connecting and canceling publication.
///
/// Use `makeConnectable()` to create a `ConnectablePublisher` from any publisher whose failure type is `Never`.
public protocol ConnectablePublisher : Publisher {
    
    /// Connects to the publisher and returns a `Cancellable` instance with which to cancel publishing.
    ///
    /// - Returns: A `Cancellable` instance that can be used to cancel publishing.
    func connect() -> Cancellable
}

extension ConnectablePublisher {
    
    /// Automates the process of connecting or disconnecting from this connectable publisher.
    ///
    /// Use `autoconnect()` to simplify working with `ConnectablePublisher` instances, such as those created with `makeConnectable()`.
    ///
    ///     let autoconnectedPublisher = somePublisher
    ///         .makeConnectable()
    ///         .autoconnect()
    ///         .subscribe(someSubscriber)
    ///
    /// - Returns: A publisher which automatically connects to its upstream connectable publisher.
    public func autoconnect() -> Publishers.Autoconnect<Self> {
        Global.RequiresImplementation()
    }
}
