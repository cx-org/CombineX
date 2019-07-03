/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.
final public class PassthroughSubject<Output, Failure> : Subject where Failure : Error {
    
    private let lock = Lock()
    private var subscriptions: [Inner] = []
    private var completion: Subscribers.Completion<Failure>?
    
    public init() { }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        self.lock.lock()
        
        if let completion = self.completion {
            subscriber.receive(subscription: Subscriptions.empty)
            subscriber.receive(completion: completion)
            self.lock.unlock()
            return
        }
        
        let subscription = Inner(pub: self, sub: AnySubscriber(subscriber))
        self.subscriptions.append(subscription)
        self.lock.unlock()
        
        subscriber.receive(subscription: subscription)
    }
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ input: Output) {
        self.lock.lock()
        let subscriptions = self.subscriptions
        self.lock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(input)
        }
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    final public func send(completion: Subscribers.Completion<Failure>) {
        self.lock.lock()
        self.completion = completion
        let subscriptions = self.subscriptions
        self.lock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(completion: completion)
        }
    }
    
    private func removeSubscription(_ subscription: Inner) {
        self.lock.lock()
        self.subscriptions.removeAll(where: { $0 === subscription })
        self.lock.unlock()
    }
}

extension PassthroughSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = PassthroughSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        var pub: Pub?
        var sub: Sub?
        
        let lock = Lock()
        var isCancelled = false
        
        var demand: Subscribers.Demand = .none
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func receive(_ value: Output) {
            self.lock.lock()
            if self.isCancelled {
                self.lock.unlock()
                return
            }

            guard self.demand > 0 else {
                self.lock.unlock()
                return
            }
            
            self.demand -= 1
            self.lock.unlock()
            
            let more = self.sub?.receive(value) ?? .none
            
            self.lock.lock()
            self.demand += more
            self.lock.unlock()
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            if self.isCancelled {
                self.lock.unlock()
                return
            }

            let sub = self.sub
            self.pub = nil
//            self.sub = nil
            self.lock.unlock()
            
            sub?.receive(completion: completion)
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            
            if self.isCancelled {
                return
            }
            
            self.demand += demand
        }
        
        func cancel() {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            
            if self.isCancelled {
                return
            }
            
            self.isCancelled = true
            
            self.pub?.removeSubscription(self)
            
            self.pub = nil
//            self.sub = nil
        }
        
        var description: String {
            return "PassthroughSubject"
        }
        
        var debugDescription: String {
            return "PassthroughSubject"
        }
    }
}
