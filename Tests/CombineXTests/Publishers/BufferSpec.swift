import CXShim
import CXTestUtility
import Nimble
import Quick

class BufferSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay-ByRequest
        describe("Relay-ByRequest") {
            
            // MARK: 1.1 should request unlimit at beginning if strategy is by request
            it("should request unlimit at beginning if strategy is by request") {
                let subject = TracingSubject<Int, TestError>()
                let pub = subject.buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(2), subsequentDemand: { [5].contains($0) ? .max(5) : .max(0) })
                
                subject.send(contentsOf: 0..<100)
                
                sub.subscription?.request(.max(2))
                
                expect(subject.subscription.requestDemandRecords) == [.unlimited, .max(2), .max(2)]
                expect(subject.subscription.syncDemandRecords) == Array(repeating: .max(0), count: 100)
            }
            
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
            
            // MARK: 1.1 should request buffer count at beginning if strategy is keep full
            it("should request buffer count at beginning if strategy is keep full") {
                let subject = TracingSubject<Int, TestError>()
                let pub = subject.buffer(size: 10, prefetch: .keepFull, whenFull: .dropOldest)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(5), subsequentDemand: { [5, 10].contains($0) ? .max(5) : .max(0) })
                
                pub.subscribe(sub)
                
                subject.send(contentsOf: 0..<100)
                
                sub.subscription?.request(.max(9))
                sub.subscription?.request(.max(5))
                
                expect(subject.subscription.requestDemandRecords) == [.max(10), .max(5), .max(19), .max(5)]
                
                let max1 = Array(repeating: Subscribers.Demand.max(1), count: 5)
                let max0 = Array(repeating: Subscribers.Demand.max(0), count: 15)
                expect(subject.subscription.syncDemandRecords) == max1 + max0
            }
        }
    }
}
