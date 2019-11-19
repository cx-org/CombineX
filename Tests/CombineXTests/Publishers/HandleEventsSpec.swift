import CXShim
import CXTestUtility
import Nimble
import Quick

class HandleEventsSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            it("should") {
                expect(1989) != 0614
            }
        }
    }
}
