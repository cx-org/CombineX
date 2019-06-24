import Foundation

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

/// The same implementation as CombineX's `PassthroughSubject`.
///
/// Since Combine's `PassthroughSubject` 
class CustomSubject<Output, Failure> : Subject where Failure : Error {
    
    private let subscriptions = Atomic<[Inner]>(value: [])
    
    init() {}
    
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
            subscription.demand.withLockMutating {
                guard $0 > 0 else {
                    return
                }
                
                let more = subscription.sub?.receive(input) ?? .none
                $0 += (more - 1)
            }
        }
    }
    
    func send(completion: Subscribers.Completion<Failure>) {
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

extension CustomSubject {
    
    private class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = CustomSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        var pub: Pub?
        var sub: Sub?
        
        let demand = Atomic<Subscribers.Demand>(value: .none)
        
        init(pub: Pub, sub: Sub) {
            self.pub = pub
            self.sub = sub
        }
        
        func request(_ demand: Subscribers.Demand) {
            self.demand.withLockMutating {
                $0 += demand
            }
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
