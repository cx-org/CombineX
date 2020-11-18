import CXShim
import CXTestUtility
import Dispatch
import Nimble
import Quick

class VersioningTimeoutSpec: QuickSpec {
    
    override func spec() {
        
        it("should not send value without demand") {
            let subject = PassthroughSubject<Int, Never>()
            let pub = subject.timeout(.seconds(0), scheduler: DispatchQueue.global().cx)
            let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
            subject.send(0)
            expect(sub.events[0].isSubscription) == true
            // SUSPICIOUS: Combine.Publishers.Timeout leaks value
            expect(sub.events.filter { $0.value != nil }.count).toVersioning([
                .v11_0: equal(1),
                .v12_0: equal(0),
            ])
        }
    }
}
