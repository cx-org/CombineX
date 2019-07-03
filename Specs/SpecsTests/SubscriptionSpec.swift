import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class SubscriptionSpec: QuickSpec {
    
    override func spec() {
        
        it("should release subscriber after cancelled") {
            var subscription: Subscription?
            weak var subscriber: CustomSubscriber<Int, Never>?
            
            do {
                let pub = Just(1)
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                }, receiveValue: { (i) -> Subscribers.Demand in
                    return .unlimited
                }, receiveCompletion: { (c) in
                    
                })
                
                pub.subscribe(sub)
                
                subscriber = sub
            }
            
            expect(subscriber).toNot(beNil())
            
            subscription?.cancel()
            
            expect(subscriber).to(beNil())
        }
    }
}

