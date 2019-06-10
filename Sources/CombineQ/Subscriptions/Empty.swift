extension Subscriptions {
    
    /// Returns the 'empty' subscription.
    ///
    /// Use the empty subscription when you need a `Subscription` that ignores requests and cancellation.
    public static var empty: Subscription {
        return EmptySubscription()
    }
}

private final class EmptySubscription: Subscription, Cancellable, CustomCombineIdentifierConvertible {
    
    func request(_ demand: Subscribers.Demand) {
    }
    
    func cancel() {
    }
}
