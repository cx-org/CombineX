import CXShim
import CXTestUtility
import Nimble
import Quick

class VersioningSwitchToLatestSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: 1.1 should finish when the last child finish
        it("should finish when the last child finish") {
            let subject1 = PassthroughSubject<Int, TestError>()
            let subject2 = PassthroughSubject<Int, TestError>()
            
            let subject = PassthroughSubject<PassthroughSubject<Int, TestError>, TestError>()
            let pub = subject.switchToLatest()
            let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
            
            subject.send(subject1)
            subject1.send(completion: .finished)
            expect(sub.eventsWithoutSubscription) == []
            
            subject.send(subject2)
            expect(sub.eventsWithoutSubscription) == []
            
            subject.send(completion: .finished)
            expect(sub.eventsWithoutSubscription) == []
            
            // VERSIONING: Combine won't get any event when the last child finish.
            subject2.send(completion: .finished)
            expect(sub.eventsWithoutSubscription).toVersioning([
                .v11_0: beEmpty(),
                .v11_4: equal([.completion(.finished)]),
            ])
        }
        
        // MARK: 1.2 should send as many values as demand
        it("should send as many values as demand") {
            let subject1 = PassthroughSubject<Int, Never>()
            let subject2 = PassthroughSubject<Int, Never>()
            
            let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
            
            let pub = subject.switchToLatest()
            let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10)) { v in
                return [1, 11].contains(v) ? .max(1) : .none
            }
            
            subject.send(subject1)
            
            (1...10).forEach(subject1.send)
            
            subject.send(subject2)
            
            (11...20).forEach(subject2.send)
            
            expect(sub.eventsWithoutSubscription.count).toVersioning([
                .v11_0: equal(10),
                .v11_4: equal(12),
            ])
        }
    }
}
