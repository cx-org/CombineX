#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CustomSubscriber<Input, Failure>: Subscriber where Failure : Error {
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?

    enum Event {
        case value(Input)
        case completion(Subscribers.Completion<Failure>)
    }
    
    var events: [Event] = []
    
    init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
    }
    
    func receive(subscription: Subscription) {
        self.receiveSubscriptionBody?(subscription)
    }
    
    func receive(_ value: Input) -> Subscribers.Demand {
        self.events.append(.value(value))
        return self.receiveValueBody?(value) ?? .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        self.events.append(.completion(completion))
        self.receiveCompletionBody?(completion)
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
