#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

func makeTestSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> TestSubscriber<Input, Failure> {
    return TestSubscriber<Input, Failure>(receiveSubscription: { (s) in
        s.request(demand)
    }, receiveValue: { v in
        return .none
    }, receiveCompletion: { c in
    })
}

enum TestEvent<Input, Failure: Error> {
    case value(Input)
    case completion(Subscribers.Completion<Failure>)
}

class TestSubscriber<Input, Failure>: Subscriber where Failure : Error {
    
    
    typealias Event = TestEvent<Input, Failure>
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?
    
    private let lock = Lock()
    private var _subscription: Subscription?
    private var _events: [Event] = []
    
    var events: [Event] {
        return self.lock.withLockGet(self._events)
    }
    
    var subscription: Subscription? {
        return self.lock.withLockGet(self._subscription)
    }
    
    init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
    }
    
    func receive(subscription: Subscription) {
        self.lock.withLock {
            self._subscription = subscription
        }
        self.receiveSubscriptionBody?(subscription)
    }
    
    func receive(_ value: Input) -> Subscribers.Demand {
        self.lock.withLock {
            self._events.append(.value(value))
        }
        return self.receiveValueBody?(value) ?? .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        self.lock.withLock {
            self._events.append(.completion(completion))
            self._subscription = nil
        }
        self.receiveCompletionBody?(completion)
    }
    
    func releaseSubscription() {
        self.lock.withLock {
            self._subscription = nil
        }
    }
}

extension TestEvent {
    
    func isFinished() -> Bool {
        switch self {
        case .value:                return false
        case .completion(let c):    return c.isFinished
        }
    }
    
    var error: Failure? {
        guard case .completion(let c) = self, case .failure(let e) = c else {
            return nil
        }
        return e
    }
    
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> TestEvent<Input, NewFailure> {
        switch self {
        case .value(let i):         return .value(i)
        case .completion(let c):    return .completion(c.mapError(transform))
        }
    }
}

extension TestEvent where Input: Equatable {
    
    func isValue(_ value: Input) -> Bool {
        switch self {
        case .value(let v):     return v == value
        case .completion:       return false
        }
    }
}

extension TestEvent: Equatable where Input: Equatable, Failure: Equatable {
    
    static func == (lhs: TestEvent, rhs: TestEvent) -> Bool {
        switch (lhs, rhs) {
        case (.value(let a), .value(let b)):            return a == b
        case (.completion(let a), .completion(let b)):
            switch (a, b) {
            case (.finished, .finished):                return true
            case (.failure(let e0), .failure(let e1)):  return e0 == e1
            default:                                    return false
            }
        default:                                        return false
        }
    }
}

extension TestEvent: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .value(let v):
            return "\(v)"
        case .completion(let c):
            return "\(c)"
        }
    }
}

protocol TestEventProtocol {
    associatedtype Input
    associatedtype Failure: Error
    
    var testEvent: TestEvent<Input, Failure> {
        get set
    }
}

extension TestEvent: TestEventProtocol {
    
    var testEvent: TestEvent<Input, Failure> {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension Collection where Element: TestEventProtocol {
    
    func mapError<NewFailure: Error>(_ transform: (Element.Failure) -> NewFailure) -> [TestEvent<Element.Input, NewFailure>] {
        return self.map {
            $0.testEvent.mapError(transform)
        }
    }
}
