import CXShim
import CXUtility

// TODO: move to CXTest
public class TracingSubject<Output, Failure: Error>: Subject {
    
    private let downstreamLock = Lock()
    private var completion: Subscribers.Completion<Failure>?
    private var downstreamSubscriptions: [Subscription] = []
    
    private let upstreamLock = Lock()
    private var isRequested = false
    private var upstreamSubscriptions: [CXShim.Subscription] = []
    
    public init() {}
    
    deinit {
        upstreamLock.cleanupLock()
        downstreamLock.cleanupLock()
    }
    
    public var subscriptions: [Subscription] {
        return self.downstreamLock.withLockGet(self.downstreamSubscriptions)
    }
    
    public var subscription: Subscription {
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
        
        let subscription = Subscription(pub: self, sub: AnySubscriber(subscriber))
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
    
    private func removeDownstreamSubscription(_ subscription: Subscription) {
        self.downstreamLock.lock()
        self.downstreamSubscriptions.removeAll(where: { $0 === subscription })
        self.downstreamLock.unlock()
    }
    
    public func send(subscription: CXShim.Subscription) {
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

// MARK: - Subscription

extension TracingSubject {
    
    public final class Subscription: CXShim.Subscription, CustomStringConvertible, CustomDebugStringConvertible {
        
        typealias Pub = TracingSubject<Output, Failure>
        typealias Sub = AnySubscriber<Output, Failure>
        
        let lock = RecursiveLock()
       
        var pub: Pub?
        var sub: Sub?
        
        enum DemandState: Equatable {
            case waiting
            case demanding(Subscribers.Demand)
            case completed
        }
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
        
        deinit {
            lock.cleanupLock()
        }
        
        func receive(_ value: Output) {
            self.lock.lock()
            
            guard let demand = self.state.demand, demand > 0 else {
                self.lock.unlock()
                return
            }
            
            self.state.sub(.max(1))
            
            let sub = self.sub!
            self.lock.unlock()
            
            // FIXME: Yes, no guarantee of synchronous backpressure. See PassthroughSubjectSpec#3.3 for more information.
            let more = sub.receive(value)
            
            self._demandRecords.withLockMutating { $0.append((.sync, more)) }
            
            self.lock.withLock {
                self.state.add(more)
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
            
            self.lock.lock()
            var pub: Pub?
            
            switch self.state {
            case .waiting:
                pub = self.pub
                self.state = .demanding(demand)
            case .demanding:
                self.state.add(demand)
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
            return "TracingSubject"
        }
        
        public var debugDescription: String {
            return "TracingSubject"
        }
    }
}

// MARK: - DemandState

extension TracingSubject.Subscription.DemandState {
    
    var demand: Subscribers.Demand? {
        switch self {
        case .demanding(let d): return d
        default:                return nil
        }
    }
}

extension TracingSubject.Subscription.DemandState {
    
    /// - Returns: `true` if the previous state is not `completed`.
    mutating func complete() -> Bool {
        if self == .completed {
            return false
        } else {
            self = .completed
            return true
        }
    }
    
    mutating func add(_ demand: Subscribers.Demand) {
        if let old = self.demand {
            self = .demanding(old + demand)
        }
    }
    
    mutating func sub(_ demand: Subscribers.Demand) {
        if let old = self.demand {
            self = .demanding(old - demand)
        }
    }
}

