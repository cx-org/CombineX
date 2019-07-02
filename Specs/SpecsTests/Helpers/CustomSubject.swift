#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CustomSubject<Output, Failure> : Subject where Failure : Error {
    
    private let lock = Lock()
    private var subscriptions: [Inner] = []
    private var completion: Subscribers.Completion<Failure>?
    
    init() { }
    
    func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
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
    
    func send(_ input: Output) {
        self.lock.lock()
        let subscriptions = self.subscriptions
        self.lock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(input)
        }
    }
    
    func send(completion: Subscribers.Completion<Failure>) {
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

extension CustomSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = CustomSubject<Output, Failure>
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
            defer {
                self.lock.unlock()
            }
            
            if self.isCancelled {
                return
            }
            
            guard self.demand > 0 else {
                return
            }
            let more = self.sub?.receive(value) ?? .none
            self.demand += (more - 1)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            if self.lock.withLock({ self.isCancelled }) {
                return
            }
            
            self.sub?.receive(completion: completion)
            self.pub = nil
            self.sub = nil
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.lock.lock()
            self.demand += demand
            self.lock.unlock()
        }
        
        func cancel() {
            self.lock.lock()
            if self.isCancelled {
                self.lock.unlock()
                return
            }
            
            self.isCancelled = true
            self.lock.unlock()
            
            self.pub?.removeSubscription(self)
            
            self.pub = nil
            self.sub = nil
        }
        
        var description: String {
            return "CustomSubject"
        }
        
        var debugDescription: String {
            return "CustomSubject"
        }
    }
}
