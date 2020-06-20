import CXShim
import CXTestUtility
import Nimble
import Quick

class DropUntilOutputSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should drop until other sends a value
            it("should drop until other sends a value") {
                
                let pub0 = PassthroughSubject<Int, TestError>()
                let pub1 = PassthroughSubject<Int, TestError>()
                
                let pub = pub0.drop(untilOutputFrom: pub1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                pub0.send(contentsOf: 0..<10)
                pub1.send(-1)
                
                for i in 10..<20 {
                    pub0.send(i)
                }
                 
                let expected = (10..<20).map(TracingSubscriber<Int, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.2 should complete when other complete
            it("should complete when other complete") {
                
                let pub0 = PassthroughSubject<Int, TestError>()
                let pub1 = PassthroughSubject<Int, TestError>()
                
                let pub = pub0.drop(untilOutputFrom: pub1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                pub0.send(contentsOf: 0..<10)
                pub1.send(completion: .finished)
                pub0.send(contentsOf: 0..<10)
                
                expect(sub.eventsWithoutSubscription) == [.completion(.finished)]
            }
            
            // MARK: 1.3 should complete if self complete
            it("should complete if self complete") {
                
                let pub0 = PassthroughSubject<Int, TestError>()
                let pub1 = PassthroughSubject<Int, TestError>()
                
                let pub = pub0.drop(untilOutputFrom: pub1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                pub0.send(contentsOf: 0..<10)
                pub0.send(completion: .finished)
                
                expect(sub.eventsWithoutSubscription) == [.completion(.finished)]
            }
        }
    }
}
