import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class VersioningTimerSpec: QuickSpec {
    
    override func spec() {
        
        it("should not add demands up from multiple subscriber") {
            let pub = CXWrappers.Timer.publish(every: 0.1, on: .current, in: .common)
            let sub1 = pub.subscribeTracingSubscriber(initialDemand: .max(1))
            let sub2 = pub.subscribeTracingSubscriber(initialDemand: .max(2))
            
            let connection = pub.connect()
            
            RunLoop.current.run(until: Date().addingTimeInterval(1))
            
            #if USE_COMBINE // FIXME: MACOS11: Apple's implementation is outdated
            expect(sub1.eventsWithoutSubscription.count).toVersioning([
                .v11_0: equal(3),
                .v12_0: equal(1)
            ])
            expect(sub2.eventsWithoutSubscription.count).toVersioning([
                .v11_0: equal(3),
                .v12_0: equal(2)
            ])
            #endif
            
            connection.cancel()
        }
    }
}
