import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class AssertNoFailureSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - No Failure
        describe("No Failure") {
            
            it("should crash if there is an error") {
                
                let pub = Publishers.Fail<Int, CustomError>(error: CustomError.e0)
                    .assertNoFailure()
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
             
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
        }
    }
}
