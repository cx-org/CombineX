import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class SuspiciousDemandSpec: QuickSpec {
    
    typealias Demand = Subscribers.Demand
    
    override func spec() {
            
        // SUSPICIOUS: Doc says "any operation that would result in a negative
        // value is clamped to .max(0)", but it will actually crash in Combine.
        it("result should clamped to .max(0) as documented") {
            #if arch(x86_64) && canImport(Darwin)
            expect {
                Demand.max(1) - .max(2)
            }.toBranch(
                combine: throwAssertion(),
                cx: equal(.max(0)))
            #endif
        }
    }
}
