import Quick
import Nimble
@testable import CXFoundation

class DoubleExtensionsSpec: QuickSpec {
    
    override func spec() {
        
        it("should clamp to int as expected") {
            expect(Double.greatestFiniteMagnitude.clampedToInt).to(equal(Int.max))
            expect((-Double.greatestFiniteMagnitude).clampedToInt).to(equal(Int.min))
        }
    }
}
