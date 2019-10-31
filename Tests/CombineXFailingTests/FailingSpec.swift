import CXShim
import Quick
import Nimble

// Example

class FailingSpec: QuickSpec {
    
    override func spec() {
        
        xdescribe("failing", flags: [:]) {
            
            it("should failing") {
                
            }
        }
    }
}
