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

