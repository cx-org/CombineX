import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CurrentValueSubjectSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should receive value when subscribe
        it("should receive value when subscribe") {
            
            let subject = CurrentValueSubject<Int, CustomError>(1)
            
            var count = 0
            
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                s.request(.max(1))
            }, receiveValue: { v in
                count += 1
                return .none
            }, receiveCompletion: { s in
            })
            
            subject.receive(subscriber: sub)
            
            expect(count).to(equal(1))
        }
    }
}
