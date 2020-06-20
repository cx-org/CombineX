import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class FixedSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: should fix https://github.com/cx-org/CombineX/issues/44
        it("should fix #44") {
            let pub = PassthroughSubject<Int, Never>()
            let sub = pub
                .debounce(for: 0.5, scheduler: DispatchQueue.global().cx)
                .subscribeTracingSubscriber(initialDemand: .unlimited)
            
            (0...10).forEach(pub.send)
            
            expect(sub.eventsWithoutSubscription).to(beEmpty())
            expect(sub.eventsWithoutSubscription).toEventually(equal([.value(10)]))
        }
    }
}
