import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class HandleEventsSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            it("should") {
                expect(1989).toNot(equal(0614))
            }
        }
    }
}
