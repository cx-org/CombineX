import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class AssertNoFailureSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - No Failure
        describe("No Failure") {
            
            #if !SWIFT_PACKAGE
            xit("should throw assertion if there is an error") {
                
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
            #endif
        }
    }
}
