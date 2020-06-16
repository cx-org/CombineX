import CXShim
import CXUtility

public class TestSubject<Output, Failure: Error>: Subject, TestLogging {
    
    private let downstreamLock = Lock()
    private var completion: Subscribers.Completion<Failure>?
    private var downstreamSubscriptions: [Inner] = []
    
    private let upstreamLock = Lock()
    private var isRequested = false
    private var upstreamSubscriptions: [Subscription] = []
    
    public let name: String?
    
    public init(name: String? = nil) {
        self.name = name
    }
    
    public var subscriptions: [Inner] {
        return self.downstreamLock.withLockGet(self.downstreamSubscriptions)
    }
    
    public var subscription: Inner {
        return self.subscriptions[0]
    }
    
    public func receive<S: Subscriber>(subscriber: S) where Output == S.Input, Failure == S.Failure {
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
    
    public func send(_ input: Output) {
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
    
    public func send(completion: Subscribers.Completion<Failure>) {
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
    
    public func send(subscription: Subscription) {
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

extension TestSubject {
    
    public final class Inner: Subscription, CustomStringConvertible, CustomDebugStringConvertible, TestLogging {
        
        typealias Pub = TestSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        let lock = Lock(recursive: true)
        
        public var name: String?
       
        var pub: Pub?
        var sub: Sub?
        
        var state: DemandState = .waiting
        
        enum DemandType {
            case request
            case sync
        }
        private let _demandRecords = LockedAtomic<[(DemandType, Subscribers.Demand)]>([])
        
        public var demandRecords: [Subscribers.Demand] {
            return self._demandRecords.load().map { $0.1 }
        }
        
        public var requestDemandRecords: [Subscribers.Demand] {
            return self._demandRecords.load().compactMap { type, demand in
                type == .request ? demand : nil
            }
        }
        
        public var syncDemandRecords: [Subscribers.Demand] {
            return self._demandRecords.load().compactMap { type, demand in
                type == .sync ? demand : nil
            }
        }
        
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
            
            // FIXME: Yes, no guarantee of synchronous backpressure. See PassthroughSubjectSpec#3.3 for more information.
            let more = sub.receive(value)
            
            self._demandRecords.withLockMutating { $0.append((.sync, more)) }
            self.trace("sync more", more)
            
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
        
        public func request(_ demand: Subscribers.Demand) {
            precondition(demand > 0)
            self._demandRecords.withLockMutating { $0.append((.request, demand)) }
            self.trace("request more", demand)
            
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
        
        public func cancel() {
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
        
        public var description: String {
            return "TestSubject"
        }
        
        public var debugDescription: String {
            return "TestSubject"
        }
    }
}
