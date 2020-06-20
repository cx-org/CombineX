import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class NotificationCenterSpec: QuickSpec {
    
    override func spec() {

        // MARK: 1.1 should send as many notications as demand
        it("should send as many notications as demand") {
            let name = Notification.Name(rawValue: UUID().uuidString)
            let pub = NotificationCenter.default.cx.publisher(for: name)
            let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
            
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            
            expect(sub.eventsWithoutSubscription).toEventually(haveCount(3))
        }
        
        // MARK: 1.2 should stop sending values after cancel
        it("should stop sending values after cancel") {
            let name = Notification.Name(rawValue: UUID().uuidString)
            let pub = NotificationCenter.default.cx.publisher(for: name)
            let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
            
            sub.subscription?.cancel()
            
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            
            expect(sub.eventsWithoutSubscription).toEventually(beEmpty())
        }
    }
}
