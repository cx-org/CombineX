import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class FixedSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: should fix https://github.com/cx-org/CombineX/issues/44
        it("should fix #44") {
            let pub = PassthroughSubject<Int, Never>()
            let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
            pub.debounce(for: 0.5, scheduler: DispatchQueue.global().cx).receive(subscriber: sub)
            
            (0...10).forEach(pub.send)
            
            expect(sub.eventsWithoutSubscription).to(beEmpty())
            expect(sub.eventsWithoutSubscription).toEventually(equal([.value(10)]))
        }
    }
}
