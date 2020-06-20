import CXShim
import CXTestUtility
import Nimble
import Quick

class MulticastSpec: QuickSpec {
    
    override func spec() {
        
        describe("Relay") {
            
            // MARK: 1.1 should multicase after connect
            it("should multicase after connect") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.multicast(subject: PassthroughSubject<Int, TestError>())
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<10)
                expect(sub.eventsWithoutSubscription) == []
                
                let cancel = pub.connect()
                
                subject.send(contentsOf: 0..<10)
                expect(sub.eventsWithoutSubscription) == (0..<10).map { .value($0) }
                
                cancel.cancel()
                
                subject.send(contentsOf: 0..<10)
                expect(sub.eventsWithoutSubscription) == (0..<10).map { .value($0) }
            }
        }
    }
}
