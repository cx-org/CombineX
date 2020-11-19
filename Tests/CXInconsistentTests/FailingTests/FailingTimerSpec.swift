import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class FailingTimerSpec: QuickSpec {
    
    override func spec() {
        
        context(minimalVersion: .v12_0) {
            
            it("should not add demands up from multiple subscriber") {
                let pub = CXWrappers.Timer.publish(every: 0.1, on: .current, in: .common)
                let sub1 = pub.subscribeTracingSubscriber(initialDemand: .max(1))
                let sub2 = pub.subscribeTracingSubscriber(initialDemand: .max(2))
                
                let connection = pub.connect()
                
                RunLoop.current.run(until: Date().addingTimeInterval(1))
                expect(sub1.eventsWithoutSubscription.count).toBranch(
                    combine: equal(1),
                    cx: equal(3))
                expect(sub2.eventsWithoutSubscription.count).toBranch(
                    combine: equal(2),
                    cx: equal(3))
                connection.cancel()
            }
        }
    }
}
