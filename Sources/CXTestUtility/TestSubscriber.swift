import CXUtility
import CXShim

public func makeTestSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> TestSubscriber<Input, Failure> {
    return TestSubscriber<Input, Failure>(receiveSubscription: { (s) in
         s.request(demand)
    }, receiveValue: { v in
        return .none
    }, receiveCompletion: { c in
    })
}

public func makeTestSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type) -> TestSubscriber<Input, Failure> {
    return TestSubscriber<Input, Failure>(receiveSubscription: { (s) in
    }, receiveValue: { v in
        return .none
    }, receiveCompletion: { c in
    })
}

public class TestSubscriber<Input, Failure: Error>: Subscriber {
    
    public typealias Event = TestSubscriberEvent<Input, Failure>
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?
    
    private let lock = Lock()
    private var _subscription: Subscription?
    private var _events: [Event] = []
    
    public var events: [Event] {
        return self.lock.withLockGet(self._events)
    }
    
    public var subscription: Subscription? {
        return self.lock.withLockGet(self._subscription)
    }
    
    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
        
        TestResources.resgiter(self)
    }
    
    public func receive(subscription: Subscription) {
        self.lock.withLock {
            self._subscription = subscription
        }
        self.receiveSubscriptionBody?(subscription)
    }
    
    public func receive(_ value: Input) -> Subscribers.Demand {
        self.lock.withLock {
            self._events.append(.value(value))
        }
        return self.receiveValueBody?(value) ?? .none
    }
    
    public func receive(completion: Subscribers.Completion<Failure>) {
        self.lock.withLock {
            self._events.append(.completion(completion))
            self._subscription = nil
        }
        self.receiveCompletionBody?(completion)
    }
}

extension TestSubscriber: TestResourceProtocol {
    
    public func release() {
        self.lock.withLock {
            self._subscription = nil
        }
    }
}

