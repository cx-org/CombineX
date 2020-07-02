import CXShim
import CXTestUtility
import Nimble
import Quick

class MergeSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: It should merge 8 upstreams
            it("should merge 8 upstreams") {
                let subjects = (0..<8).map { _ in PassthroughSubject<Int, TestError>() }
                let pub = Publishers.Merge8(
                    subjects[0], subjects[1], subjects[2], subjects[3],
                    subjects[4], subjects[5], subjects[6], subjects[7]
                    )
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                100.times {
                    subjects.randomElement()!.send($0)
                }
                
                let events = (0..<100).map(TracingSubscriber<Int, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == events
            }
            
            // MARK: It should merge many upstreams
            it("should merge many upstreams") {
                let subjects = (0..<9).map { _ in PassthroughSubject<Int, TestError>() }
                let pub = Publishers.MergeMany(subjects)
                
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                100.times {
                    subjects.randomElement()!.send($0)
                }
                
                let events = (0..<100).map(TracingSubscriber<Int, TestError>.Event.value)
                expect(sub.eventsWithoutSubscription) == events
            }
        }
    }
}
