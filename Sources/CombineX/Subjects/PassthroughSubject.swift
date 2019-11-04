#if !COCOAPODS
import CXUtility
#endif

/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.
final public class PassthroughSubject<Output, Failure> : Subject where Failure : Error {
    
    private let downstreamLock = Lock()
    private var completion: Subscribers.Completion<Failure>?
    private var downstreamSubscriptions: [Inner] = []
    
    private let upstreamLock = Lock()
    private var isRequested = false
    private var upstreamSubscriptions: [Subscription] = []
    
    public init() { }
    
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
    
    /// Sends a value to the subscriber.
    ///
    /// - Parameter value: The value to send.
    final public func send(_ input: Output) {
        self.downstreamLock.lock()
        guard self.completion == nil else {
            self.downstreamLock.unlock()
            return
        }
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

extension PassthroughSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = PassthroughSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        let lock = Lock()
        let downstreamLock = Lock(recursive: true)
        
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
            
            // FIXME: Yes, no guarantee of synchronous backpressure. See PassthroughSubjectSpec#4.3 for more information.
            self.downstreamLock.lock()
            let more = sub.receive(value)
            self.downstreamLock.unlock()
            
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
            
            self.downstreamLock.lock()
            sub.receive(completion: completion)
            self.downstreamLock.unlock()
        }
        
        func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            
            self.lock.lock()
            var pub: Pub?
            
            switch self.state {
            case .waiting:
                pub = self.pub
                self.state = .demanding(demand)
            case .demanding:
                _ = self.state.add(demand)
            case .completed:
                break
            }
            self.lock.unlock()
            
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
            return "PassthroughSubject"
        }
        
        var debugDescription: String {
            return "PassthroughSubject"
        }
    }
}
