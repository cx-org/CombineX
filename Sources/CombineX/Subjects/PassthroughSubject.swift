/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.
final public class PassthroughSubject<Output, Failure> : Subject where Failure : Error {
    
    private let subscriptions = Atomic<[Inner]>(value: [])
    
    public init() { }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        let subscription = Inner(pub: self, sub: AnySubscriber(subscriber))
        self.subscriptions.withLockMutating {
            $0.append(subscription)
        }
        subscriber.receive(subscription: subscription)
    }
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ input: Output) {
        let subscriptions = self.subscriptions.load()
        
        // FIXME: Yes, here is thread-unsafe. Because Combine's PassthroughSubject seems to be also thread-unsafe. This doesn't accord with my intuition, you can see `PassthroughSubjectSpec` for more information.
        for subscription in subscriptions where subscription.demand > 0 {
            let more = subscription.sub?.receive(input) ?? .none
            subscription.demand += (more - 1)
        }
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    final public func send(completion: Subscribers.Completion<Failure>) {
        let subscriptions = self.subscriptions.exchange(with: [])
        
        for subscription in subscriptions {
            subscription.sub?.receive(completion: completion)
            
            subscription.pub = nil
            subscription.sub = nil
        }
    }
    
    private func removeSubscription(_ subscription: Inner) {
        self.subscriptions.withLockMutating {
            $0.removeAll(where: { $0 === subscription })
        }
    }
}

extension PassthroughSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = PassthroughSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        var pub: Pub?
        var sub: Sub?
        
        var demand: Subscribers.Demand = .none
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
        }
        
        func cancel() {
            self.pub?.removeSubscription(self)
            
            self.pub = nil
            self.sub = nil
        }
        
        var description: String {
            return "PassthroughSubject"
        }
        
        var debugDescription: String {
            return "PassthroughSubject"
        }
    }
}
