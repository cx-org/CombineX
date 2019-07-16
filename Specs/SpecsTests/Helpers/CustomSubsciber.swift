#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

func makeCustomSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> CustomSubscriber<Input, Failure> {
    return CustomSubscriber<Input, Failure>(receiveSubscription: { (s) in
        s.request(demand)
    }, receiveValue: { v in
        return .none
    }, receiveCompletion: { c in
    })
}

enum CustomEvent<Input, Failure: Error> {
    case value(Input)
    case completion(Subscribers.Completion<Failure>)
}

class CustomSubscriber<Input, Failure>: Subscriber where Failure : Error {
    
    
    typealias Event = CustomEvent<Input, Failure>
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?
    
    private let lock = Lock()
    private var _events: [Event] = []
    
    var events: [Event] {
        return self.lock.withLockGet(self._events)
    }
    
    init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
    }
    
    func receive(subscription: Subscription) {
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
        }
        self.receiveCompletionBody?(completion)
    }
}

extension CustomEvent {
    
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
    
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> CustomSubscriber<Input, NewFailure>.Event {
        switch self {
        case .value(let i):         return .value(i)
        case .completion(let c):    return .completion(c.mapError(transform))
        }
    }
}

extension CustomEvent where Input: Equatable {
    
    func isValue(_ value: Input) -> Bool {
        switch self {
        case .value(let v):     return v == value
        case .completion:       return false
        }
    }
}

extension CustomEvent: Equatable where Input: Equatable, Failure: Equatable {
    
    static func == (lhs: CustomEvent, rhs: CustomEvent) -> Bool {
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

extension CustomEvent: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .value(let v):
            return "\(v)"
        case .completion(let c):
            return "\(c)"
        }
    }
}
