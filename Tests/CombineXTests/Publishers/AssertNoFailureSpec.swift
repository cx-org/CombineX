import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class AssertNoFailureSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - No Failure
        describe("No Failure") {
            
            #if !SWIFT_PACKAGE
            it("should throw assertion if there is an error") {
                
                let pub = Fail<Int, TestError>(error: .e0)
                    .assertNoFailure()
                let sub = makeTestSubscriber(Int.self, Never.self, .max(0))
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
