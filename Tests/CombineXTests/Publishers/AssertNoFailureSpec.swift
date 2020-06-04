import CXShim
import CXTestUtility
import Nimble
import Quick

class AssertNoFailureSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - No Failure
        describe("No Failure") {
            
            #if !SWIFT_PACKAGE
            it("should throw assertion if there is an error") {
                
                let pub = Fail<Int, TestError>(error: .e0)
                    .assertNoFailure()
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
