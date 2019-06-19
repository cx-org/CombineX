import Quick
import Nimble

#if CombineX
import CombineX
#else
import Combine
#endif

class SubscriptionSpec: QuickSpec {
    
    override func spec() {
        
        it("should release subscriber after cancelled") {
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
            
            expect(subscriber).toNot(beNil())
            
            subscription?.cancel()
            
            expect(subscriber).to(beNil())
        }
    }
}

