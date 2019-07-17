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
            it("should throw assertion if there is an error") {
                
                let pub = Publishers.Fail<Int, CustomError>(error: .e0)
                    .assertNoFailure()
                let sub = makeCustomSubscriber(Int.self, Never.self, .none)
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
