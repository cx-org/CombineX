#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class TestSubject<Output, Failure> : Subject where Failure : Error {
    
    private let lock = Lock()
    private var subscriptions: [Inner] = []
    private var completion: Subscribers.Completion<Failure>?
    
    let name: String
    var isLogEnabled = false
    
    init(name: String = "Anonym") {
        self.name = name
    }
    
    var inners: [Inner] {
        return self.lock.withLockGet(self.subscriptions)
    }
    
    var inner: Inner {
        return self.inners[0]
    }
    
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

extension TestSubject {
    
    final class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = TestSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        var pub: Pub?
        var sub: Sub
        
        let lock = Lock(recursive: true)
        var isCancelled = false
        var demand: Subscribers.Demand = .none
        
        enum DemandType {
            case request
            case sync
        }
        let demandRecords = Atom<[(DemandType, Subscribers.Demand)]>(val: [])
        
        var requestDemandRecords: [Subscribers.Demand] {
            return self.demandRecords.get().compactMap { (type, demand) in
                type == .request ? demand : nil
            }
        }
        
        var syncDemandRecords: [Subscribers.Demand] {
            return self.demandRecords.get().compactMap { (type, demand) in
                type == .sync ? demand : nil
            }
        }
        
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
            
            self.demandRecords.withLockMutating { $0.append((.sync, more))}
            if let pub = self.pub, pub.isLogEnabled {
                Swift.print("TestSubject-\(pub.name) sync more:", more)
            }
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
            
            self.demandRecords.withLockMutating { $0.append((.request, demand))}
            if let pub = self.pub, pub.isLogEnabled {
                Swift.print("TestSubject-\(pub.name) request more:", demand)
            }
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
            return "TestSubject"
        }
        
        var debugDescription: String {
            return "TestSubject"
        }
    }
}
