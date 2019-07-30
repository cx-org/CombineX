/// A publisher that exposes a method for outside callers to publish elements.
///
/// A subject is a publisher that you can use to ”inject” values into a stream, by calling its `send()` method. This can be useful for adapting existing imperative code to the Combine model.
public protocol Subject : AnyObject, Publisher {
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    func send(_ value: Self.Output)
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    func send(completion: Subscribers.Completion<Self.Failure>)
    
    /// Provides this Subject an opportunity to establish demand for any new upstream subscriptions (say via, ```Publisher.subscribe<S: Subject>(_: Subject)`
    func send(subscription: Subscription)
}

extension Subject where Self.Output == Void {
    
    /// Signals subscribers.
    public func send() {
        self.send(())
    }
}

extension Publisher {
    
    public func subscribe<S>(_ subject: S) -> AnyCancellable where S : Subject, Self.Failure == S.Failure, Self.Output == S.Output {
        let sub = AnySubscriber(subject)
        self.subscribe(sub)
        return AnyCancellable {
            sub.box.cancel()
        }
    }
}

