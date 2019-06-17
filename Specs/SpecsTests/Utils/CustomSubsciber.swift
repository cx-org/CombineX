#if CombineX
import CombineX
#else
import Combine
#endif

class CustomSubscriber<Input, Failure>: Subscriber where Failure : Error {
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?
    
    init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
    }
    
    func receive(subscription: Subscription) {
        self.receiveSubscriptionBody?(subscription)
    }
    
    func receive(_ value: Input) -> Subscribers.Demand {
        return self.receiveValueBody?(value) ?? .none
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletionBody?(completion)
    }
    
    deinit {
        print("CustomSubscriber Deinit")
    }
}
