#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CustomSubject<Output, Failure> : Subject where Failure : Error {
    
    private let subscriptions = Atomic<[Inner]>(value: [])
    
    init() { }
    
    func receive<S>(subscriber: S) where Output == S.Input, Failure == S.Failure, S : Subscriber {
        let subscription = Inner(pub: self, sub: AnySubscriber(subscriber))
        self.subscriptions.withLockMutating {
            $0.append(subscription)
        }
        subscriber.receive(subscription: subscription)
    }
    
    func send(_ input: Output) {
        let subscriptions = self.subscriptions.load()
        
        for subscription in subscriptions {
            subscription.receive(input)
        }
    }
    
    func send(completion: Subscribers.Completion<Failure>) {
        let subscriptions = self.subscriptions.exchange(with: [])
        
        for subscription in subscriptions {
            subscription.receive(completion: completion)
        }
    }
    
    private func removeSubscription(_ subscription: Inner) {
        self.subscriptions.withLockMutating {
            $0.removeAll(where: { $0 === subscription })
        }
    }
}

extension CustomSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = CustomSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        var pub: Pub?
        var sub: Sub?
        
        let lock = Lock()
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
            
            guard self.demand > 0 else {
                return
            }
            let more = self.sub?.receive(value) ?? .none
            self.demand += (more - 1)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
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
