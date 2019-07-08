#if USE_COMBINE
import Combine
#else
import CombineX
#endif

func makeCustomSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> CustomSubscriber<Input, Failure> {
    return CustomSubscriber<Input, Failure>(receiveSubscription: { (s) in
        s.request(demand)
    }, receiveValue: { v in
        return .none
    }, receiveCompletion: { c in
    })
}

class CustomSubscriber<Input, Failure>: Subscriber where Failure : Error {
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?

    enum Event {
        case value(Input)
        case completion(Subscribers.Completion<Failure>)
    }
    
    let lock = Lock()
    var _events: [Event] = []
    
    var events: [Event] {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        
        return self._events
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
        self.lock.lock()
        self._events.append(.value(value))
        self.lock.unlock()
        return self.receiveValueBody?(value) ?? .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        self.lock.lock()
        self._events.append(.completion(completion))
        self.lock.unlock()
        self.receiveCompletionBody?(completion)
    }
}

extension CustomSubscriber.Event {
    
    func isFinished() -> Bool {
        switch self {
        case .value:
            return false
        case .completion(let c):
            return c.isFinished
        }
    }
    
    var error: Failure? {
        guard case .completion(let c) = self, case .failure(let e) = c else {
            return nil
        }
        return e
    }
}

extension CustomSubscriber.Event where Input: Equatable {
    
    func isValue(_ value: Input) -> Bool {
        switch self {
        case .value(let v):
            return v == value
        case .completion:
            return false
        }
    }
}

extension CustomSubscriber.Event: Equatable where Input: Equatable, Failure: Equatable {
    
    static func == (lhs: CustomSubscriber.Event, rhs: CustomSubscriber.Event) -> Bool {
        switch (lhs, rhs) {
        case (.value(let v0), .value(let v1)):
            return v0 == v1
        case (.completion(let c0), .completion(let c1)):
            switch (c0, c1) {
            case (.finished, .finished):
                return true
            case (.failure(let e0), .failure(let e1)):
                return e0 == e1
            default:
                return false
            }
        default:
            return false
        }
    }
}

extension CustomSubscriber.Event: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .value(let i):
            return "\(i)"
        case .completion(let c):
            return "\(c)"
        }
    }
}
