#if !COCOAPODS
import CXUtility
#endif

/// A subject that passes along values and completion.
///
/// Use a `PassthroughSubject` in unit tests when you want a publisher than can publish specific values on-demand during tests.
public final class PassthroughSubject<Output, Failure: Error>: Subject {
    
    private let downstreamLock = Lock()
    private var completion: Subscribers.Completion<Failure>?
    private var downstreamSubscriptions: [Inner] = []
    
    private let upstreamLock = Lock()
    private var isRequested = false
    private var upstreamSubscriptions: [Subscription] = []
    
    public init() { }
    
    deinit {
        upstreamLock.cleanupLock()
        downstreamLock.cleanupLock()
    }
    
    public final func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
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
    
    public final func send(_ input: Output) {
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
    
    public final func send(completion: Subscribers.Completion<Failure>) {
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
    
    public final func send(subscription: Subscription) {
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
        
        var pub: Pub?
        var sub: Sub?

        var state: DemandState = .waiting
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        deinit {
            lock.cleanupLock()
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
            
            // FIXME: Yes, no guarantee of synchronous backpressure. See PassthroughSubjectSpec#3.3 for more information.
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
