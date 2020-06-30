import CXShim
import CXTestUtility
import Nimble
import Quick

class SuspiciousBufferSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: 1.4 should throw an error when full
        it("should throw an error when full") {
            let subject = PassthroughSubject<Int, TestError>()
            let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .customError({ TestError.e1 }))
            let sub = pub.subscribeTracingSubscriber(initialDemand: .max(5))
            
            subject.send(contentsOf: 0..<100)
            
            // SUSPICIOUS: Apple's combine doesn't receive error.
            let valueEvents = (0..<5).map(TracingSubscriber<Int, TestError>.Event.value)
            let expected = valueEvents + [.completion(.failure(.e1))]
            expect(sub.eventsWithoutSubscription).toBranch(
                combine: equal(valueEvents),
                cx: equal(expected))
        }
    }
}
