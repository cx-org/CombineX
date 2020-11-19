import CXShim
import CXTestUtility
import Nimble
import Quick

class BufferSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay-ByRequest
        describe("Relay-ByRequest") {
            
            // MARK: 1.2 should drop oldest
            it("should drop oldest") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(5))
                
                subject.send(contentsOf: 0..<11)
                
                sub.subscription?.request(.max(5))
                
                let expected = (Array(0..<5) + Array(6..<11))
                    .map(TracingSubscriber<Int, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.3 should drop newest
            it("should drop newest") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .dropNewest)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(5))
                
                subject.send(contentsOf: 0..<11)
                
                sub.subscription?.request(.max(5))
                
                let expected = (0..<10).map(TracingSubscriber<Int, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
        }
         
        // MARK: - Realy-KeepFull
        describe("KeepFull") {
            
        }
    }
}
