import CXShim
import CXTestUtility
import Nimble
import Quick

class MulticastSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        describe("Relay") {
            
            // MARK: 1.1 should multicase after connect
            it("should multicase after connect") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.multicast(subject: PassthroughSubject<Int, TestError>())
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                10.times {
                    subject.send($0)
                }
                expect(sub.eventsWithoutSubscription) == []
                
                let cancel = pub.connect()
                
                10.times {
                    subject.send($0)
                }
                expect(sub.eventsWithoutSubscription) == (0..<10).map { .value($0) }
                
                cancel.cancel()
                
                10.times {
                    subject.send($0)
                }
                
                expect(sub.eventsWithoutSubscription) == (0..<10).map { .value($0) }
            }
        }
    }
}
