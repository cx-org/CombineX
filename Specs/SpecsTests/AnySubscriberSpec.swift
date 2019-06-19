import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class AnySubscriberSpec: QuickSpec {
    
    override func spec() {
        
        it("should receive value as demand") {
            let subject = PassthroughSubject<Int, Error>()
            let subscriber = AnySubscriber(subject)
            
            let subscription = CustomSubscription(request: { (demand) in
                expect(demand).to(equal(Subscribers.Demand.unlimited))
            }, cancel: {
            })
            
            let pub = AnyPublisher<Int, Error> { (s) in
                s.receive(subscription: subscription)
                expect(s.receive(1)).to(equal(Subscribers.Demand.none))
            }
            
            pub.subscribe(subscriber)
        }
    }
}
