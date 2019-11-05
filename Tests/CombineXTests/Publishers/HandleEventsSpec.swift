import CXShim
import CXTestUtility
import Quick
import Nimble

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
