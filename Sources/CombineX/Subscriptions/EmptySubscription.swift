extension Subscriptions {
    
    /// Returns the 'empty' subscription.
    ///
    /// Use the empty subscription when you need a `Subscription` that ignores requests and cancellation.
    public static let empty: Subscription = EmptySubscription()
}

extension Subscriptions {
    
    private final class EmptySubscription: Subscription, Cancellable, CustomCombineIdentifierConvertible {
        
        func request(_ demand: Subscribers.Demand) {
        }
        
        func cancel() {
        }
    }
}
