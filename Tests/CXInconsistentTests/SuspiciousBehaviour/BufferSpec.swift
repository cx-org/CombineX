import CXShim
import CXTestUtility
import Quick
import Nimble

class SuspiciousBufferSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: 1.4 should throw an error when full
        it("should throw an error when full") {
            let subject = PassthroughSubject<Int, TestError>()
            let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .customError({ TestError.e1 }))
            let sub = makeTestSubscriber(Int.self, TestError.self, .max(5))
            pub.subscribe(sub)
            
            100.times {
                subject.send($0)
            }
            
            // FIXME: Apple's combine doesn't receive error.
            let valueEvents = Array(0..<5).map { TestSubscriberEvent<Int, TestError>.value($0) }
            let expected = valueEvents + [.completion(.failure(.e1))]
            expect(sub.events).toBranch(
                combine: equal(valueEvents),
                cx: equal(expected))
        }
    }
}
