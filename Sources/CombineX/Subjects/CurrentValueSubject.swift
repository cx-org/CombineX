/// A subject that wraps a single value and publishes a new element whenever the value changes.
final public class CurrentValueSubject<Output, Failure> : Subject where Failure : Error {
    
    /// The value wrapped by this subject, published as a new element whenever it changes.
    final public var value: Output {
        get {
            return self.downstreamLock.withLock {
                self.current
            }
        }
        set {
            self.update(newValue)
        }
    }
    
    private let downstreamLock = Lock()
    private var current: Output
    private var downstreamSubscriptions: [Inner] = []
    private var completion: Subscribers.Completion<Failure>?
    
    private let upstreamLock = Lock()
    private var isRequested = false
    private var upstreamSubscriptions: [Subscription] = []
    
    /// Creates a current value subject with the given initial value.
    ///
    /// - Parameter value: The initial value to publish.
    public init(_ value: Output) {
        self.current = value
    }
    
    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    final public func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        self.downstreamLock.lock()
        
        if let completion = self.completion {
            self.downstreamLock.unlock()
            subscriber.receive(subscription: Subscriptions.empty)
            subscriber.receive(completion: completion)
            return
        }
        
        let subscription = Inner(pub: self, sub: AnySubscriber(subscriber))
        self.downstreamSubscriptions.append(subscription)
        self.downstreamLock.unlock()
        
        subscriber.receive(subscription: subscription)
    }
    
    private func update(_ new: Output) {
        self.downstreamLock.lock()
        self.current = new
        
        guard self.completion == nil else {
            self.downstreamLock.unlock()
            return
        }
        
        let subscriptions = self.downstreamSubscriptions
        self.downstreamLock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(new)
        }
    }
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ input: Output) {
        self.downstreamLock.lock()
        guard self.completion == nil else {
            self.downstreamLock.unlock()
            return
        }
        self.current = input
        let subscriptions = self.downstreamSubscriptions
        self.downstreamLock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(input)
        }
    }
    
    /// Sends a completion signal to the subscriber.
    ///
    /// - Parameter completion: A `Completion` instance which indicates whether publishing has finished normally or failed with an error.
    final public func send(completion: Subscribers.Completion<Failure>) {
        self.downstreamLock.lock()
        guard self.completion == nil else {
            self.downstreamLock.unlock()
            return
        }
        self.completion = completion
        let subscriptions = self.downstreamSubscriptions
        self.downstreamSubscriptions = []
        self.downstreamLock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(completion: completion)
        }
    }
    
    private func removeDownstreamSubscription(_ subscription: Inner) {
        self.downstreamLock.lock()
        self.downstreamSubscriptions.removeAll(where: { $0 === subscription })
        self.downstreamLock.unlock()
    }
    
    /// Provides this Subject an opportunity to establish demand for any new upstream subscriptions (say via, ```Publisher.subscribe<S: Subject>(_: Subject)`
    final public func send(subscription: Subscription) {
        self.upstreamLock.lock()
        self.upstreamSubscriptions.append(subscription)
        let isRequested = self.isRequested
        self.upstreamLock.unlock()
        
        if isRequested {
            subscription.request(.unlimited)
        }
    }
    
    private func requestDemandUpstream() {
        self.upstreamLock.lock()
        if self.isRequested {
            self.upstreamLock.unlock()
            return
        }
        
        self.isRequested = true
        let subscriptions = self.upstreamSubscriptions
        self.upstreamLock.unlock()
        
        subscriptions.forEach {
            $0.request(.unlimited)
        }
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
            var pub: Pub?
            
            switch self.state {
            case .waiting:
                pub = self.pub
                
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
            
            pub?.requestDemandUpstream()
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
            
            pub?.removeDownstreamSubscription(self)
        }
        
        var description: String {
            return "CurrentValueSubject"
        }
        
        var debugDescription: String {
            return "CurrentValueSubject"
        }
    }
}
