import CXShim
import CXTestUtility
import Nimble
import Quick

class RemoveDuplicatesSpec: QuickSpec {
    
    override func spec() {
        
        it("should ignore duplicate value") {
            let subject = PassthroughSubject<Int, Never>()
            let pub = subject.removeDuplicates()
            let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
            
            subject.send(1)
            subject.send(1)
            subject.send(2)
            subject.send(2)
            subject.send(1)
            subject.send(1)
            subject.send(completion: .finished)
            
            let events = [1, 2, 1].map(TracingSubscriber<Int, Never>.Event.value)
            let expected = events + [.completion(.finished)]
            expect(sub.eventsWithoutSubscription) == expected
        }
    }
}
