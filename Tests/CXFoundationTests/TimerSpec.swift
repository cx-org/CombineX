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
        
        // MARK: 1.3 should add demands up from multiple subscriber
        it("should add demands up from multiple subscriber") {
            let pub = CXWrappers.Timer.publish(every: 0.1, on: .current, in: .common)
            let sub1 = pub.subscribeTracingSubscriber(initialDemand: .max(1))
            let sub2 = pub.subscribeTracingSubscriber(initialDemand: .max(2))
            
            let connection = pub.connect()
            
            RunLoop.current.run(until: Date().addingTimeInterval(1))
            
            expect(sub1.eventsWithoutSubscription.count) == 3
            expect(sub2.eventsWithoutSubscription.count) == 3
            
            connection.cancel()
        }
    }
}
