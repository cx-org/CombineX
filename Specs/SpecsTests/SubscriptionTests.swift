import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class SubscriptionTests: XCTestCase {
    
    func testCancel() {
        
        var subscription: Subscription?
        weak var subscriber: CustomSubscriber<Int, Never>?
        
        do {
            let pub = Publishers.Just(1)
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                subscription = s
            }, receiveValue: { (i) -> Subscribers.Demand in
                return .unlimited
            }, receiveCompletion: { (c) in
                
            })
            
            pub.subscribe(sub)
            
            subscriber = sub
        }
        
        XCTAssertNotNil(subscriber)
        
        subscription?.cancel()
        
        XCTAssertNil(subscriber)
    }
}

private class CustomSubscriber<Input, Failure>: Subscriber where Failure : Error {
    
    private let receiveSubscriptionBody: ((Subscription) -> Void)?
    private let receiveValueBody: ((Input) -> Subscribers.Demand)?
    private let receiveCompletionBody: ((Subscribers.Completion<Failure>) -> Void)?
    
    public init(receiveSubscription: ((Subscription) -> Void)? = nil, receiveValue: ((Input) -> Subscribers.Demand)? = nil, receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil) {
        self.receiveSubscriptionBody = receiveSubscription
        self.receiveValueBody = receiveValue
        self.receiveCompletionBody = receiveCompletion
    }
    
    public func receive(subscription: Subscription) {
        self.receiveSubscriptionBody?(subscription)
    }

    public func receive(_ value: Input) -> Subscribers.Demand {
        return self.receiveValueBody?(value) ?? .none
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        self.receiveCompletionBody?(completion)
    }
    
    deinit {
        print("CustomSubscriber Deinit")
    }
}
