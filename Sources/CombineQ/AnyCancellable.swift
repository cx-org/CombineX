import Foundation

/// A type-erasing cancellable object that executes a provided closure when canceled.
///
/// Subscriber implementations can use this type to provide a “cancellation token” that makes it possible for a caller to cancel a publisher, but not to use the `Subscription` object to request items.
final public class AnyCancellable: Cancellable {
    
    private let cancelBody: () -> Void

    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancel: @escaping () -> Void) {
        self.cancelBody = cancel
    }
    
    public init<C>(_ canceller: C) where C: Cancellable {
        self.cancelBody = {
            canceller.cancel()
        }
    }
    
    /// Cancel the activity.
    final public func cancel() {
        self.cancelBody()
    }
    
    deinit {
        self.cancelBody()
    }
}
