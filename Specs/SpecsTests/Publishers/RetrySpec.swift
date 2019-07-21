import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class RetrySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            it("should retry specified times") {
            }
        }
    }
}
