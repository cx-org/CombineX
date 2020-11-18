import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class TimerSpec: QuickSpec {
    
    override func spec() {

        // MARK: 1.1 should not send values before connect
        it("should not send values before connect") {
            let pub = CXWrappers.Timer.publish(every: 0.1, on: .main, in: .common)
            let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
            
            waitUntil(timeout: .seconds(3)) { done in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    done()
                    expect(sub.eventsWithoutSubscription).to(beEmpty())
                }
            }
        }
        
        // MARK: 1.2 should send values repeatedly
        it("should send values repeatedly") {
            let pub = CXWrappers.Timer.publish(every: 0.1, on: .main, in: .common)
            let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
            
            let connection = pub.connect()
            
            expect(sub.eventsWithoutSubscription).toEventually(haveCount(4))
            
            _ = connection
        }
    }
}
