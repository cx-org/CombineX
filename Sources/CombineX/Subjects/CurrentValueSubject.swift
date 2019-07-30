/// A subject that wraps a single value and publishes a new element whenever the value changes.
final public class CurrentValueSubject<Output, Failure> : Subject where Failure : Error {
    
    /// The value wrapped by this subject, published as a new element whenever it changes.
    final public var value: Output {
        get {
            return self.lock.withLock {
                self.current
            }
        }
        set {
            self.update(newValue)
        }
    }
    
    private let lock = Lock()
    private var current: Output
    private var subscriptions: [Inner] = []
    private var completion: Subscribers.Completion<Failure>?
    
    /// Creates a current value subject with the given initial value.
    ///
    /// - Parameter value: The initial value to publish.
    public init(_ value: Output) {
        self.current = value
    }
    
    /// Provides this Subject an opportunity to establish demand for any new upstream subscriptions (say via, ```Publisher.subscribe<S: Subject>(_: Subject)`
    final public func send(subscription: Subscription) {
        Global.RequiresImplementation()
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        self.lock.lock()
        
        if let completion = self.completion {
            self.lock.unlock()
            subscriber.receive(subscription: Subscriptions.empty)
            subscriber.receive(completion: completion)
            return
        }
        
        let subscription = Inner(pub: self, sub: AnySubscriber(subscriber))
        self.subscriptions.append(subscription)
        self.lock.unlock()
        
        subscriber.receive(subscription: subscription)
    }
    
    private func update(_ new: Output) {
        self.lock.lock()
        self.current = new
        
        guard self.completion == nil else {
            self.lock.unlock()
            return
        }
        
        let subscriptions = self.subscriptions
        self.lock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(new)
        }
    }
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ input: Output) {
        self.lock.lock()
        guard self.completion == nil else {
            self.lock.unlock()
            return
        }
        self.current = input
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
        guard self.completion == nil else {
            self.lock.unlock()
            return
        }
        self.completion = completion
        let subscriptions = self.subscriptions
        self.subscriptions = []
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

extension CurrentValueSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = CurrentValueSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        let lock = Lock()
        
        var pub: Pub?
        var sub: Sub?
        
        var state: DemandState = .waiting
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func receive(_ value: Output) {
            self.lock.lock()
            
            guard let demand = self.state.demand, demand > 0 else {
                self.lock.unlock()
                return
            }
            
            _ = self.state.sub(.max(1))
            
            let sub = self.sub!
            self.lock.unlock()
            
            // FIXME: Yes, no guarantee of synchronous backpressure. See CurrentValueSubjectSpec#4.3 for more information.
            let more = sub.receive(value)
            
            self.lock.withLock {
                _ = self.state.add(more)
            }
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            guard self.state.complete() else {
                self.lock.unlock()
                return
            }
            
            self.pub = nil
            let sub = self.sub!
            self.sub = nil
            self.lock.unlock()
            
            sub.receive(completion: completion)
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            
            self.lock.lock()
            switch self.state {
            case .waiting:
                self.state = .demanding(demand - 1)
                let sub = self.sub!
                let current = self.pub!.value
                self.lock.unlock()
                
                let more = sub.receive(current)
                
                self.lock.withLock {
                    _ = self.state.add(more)
                }
            case .demanding:
                _ = self.state.add(demand)
                self.lock.unlock()
                return
            case .completed:
                self.lock.unlock()
                return
            }
        }
        
        func cancel() {
            self.lock.lock()
            
            guard self.state.complete() else {
                self.lock.unlock()
                return
            }
            
            let pub = self.pub
            self.pub = nil
            self.sub = nil
            self.lock.unlock()
            
            pub?.removeSubscription(self)
        }
        
        var description: String {
            return "CurrentValueSubject"
        }
        
        var debugDescription: String {
            return "CurrentValueSubject"
        }
    }
}
