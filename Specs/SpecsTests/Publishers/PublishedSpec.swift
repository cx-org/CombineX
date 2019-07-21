import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

#if swift(>=5.1)
class PublishedSpec: QuickSpec {
    
    override func spec() {
        
        describe("test") {
            
            it("test") {
            }
        }
    }
}
#endif
