import CXShim
import CXTestUtility
import Dispatch
import Nimble
import Quick

class SuspiciousTimeoutSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        it("should not send value without demand") {
            let subject = PassthroughSubject<Int, Never>()
            let pub = subject.timeout(.milliseconds(1), scheduler: DispatchQueue.global().cx)
            let sub = pub.subscribeTracingSubscriber()
            subject.send(0)
            expect(sub.events[0].isSubscription) == true
            // Combine.Publishers.Timeout leak value
            expect(sub.events.count).toBranch(
                combine: equal(2),
                cx: equal(1))
        }
    }
}
