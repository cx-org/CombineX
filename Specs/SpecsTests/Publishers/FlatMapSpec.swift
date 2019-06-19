import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class FlatMapSpec: QuickSpec {
    
    override func spec() {
        
        it("should receive sub-subscriber's value") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
            
            let pub = sequence
                .flatMap {
                    Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
            }
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            expect(sub.events.count).to(equal(10))
        }
    }

}
