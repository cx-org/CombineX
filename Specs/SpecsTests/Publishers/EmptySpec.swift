import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class EmptySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should send completion immediately
        it("should send completion immediately") {
            let empty = Publishers.Empty<Int, Never>()
            
            var count = 0
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
            }, receiveValue: { v in
                count += 1
                return .none
            }, receiveCompletion: { s in
                count += 1
            })
            
            empty.subscribe(sub)
            
            expect(count).to(equal(1))
        }
        
        // MARK: It should equal if 'immediately' are the same
        it("should equal if 'immediately' are the same") {
            
            let e1 = Publishers.Empty<Int, Never>()
            let e2 = Publishers.Empty<Int, Never>()
            let e3 = Publishers.Empty<Int, Never>(completeImmediately: false)
            
            expect(e1).to(equal(e2))
            expect(e1).toNot(equal(e3))
        }
    }

}
