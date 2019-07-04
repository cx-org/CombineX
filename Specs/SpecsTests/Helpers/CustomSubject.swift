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
        guard self.completion == nil else {
            self.lock.unlock()
            return
        }
        let subscriptions = self.subscriptions
        self.lock.unlock()
        
        for subscription in subscriptions {
            subscription.receive(input)
        }
    }
    
    func send(completion: Subscribers.Completion<Failure>) {
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

extension CustomSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = CustomSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        var pub: Pub?
        var sub: Sub
        
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
            
            self.demand -= 1
            let more = self.sub.receive(value)
            self.demand += more
            
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            
            if self.isCancelled {
                return
            }
            
            self.pub = nil
            self.sub.receive(completion: completion)
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
            
            let pub = self.pub
            self.pub = nil
            
            pub?.removeSubscription(self)
        }
        
        var description: String {
            return "CustomSubject"
        }
        
        var debugDescription: String {
            return "CustomSubject"
        }
    }
}
