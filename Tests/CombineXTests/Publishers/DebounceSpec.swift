import CXShim
import CXTestUtility
import Nimble
import Quick

class DebounceSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should ignore the values before the due time is passed
            it("should ignore the values before the due time is passed") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(1)
                subject.send(2)
                scheduler.advance(by: .seconds(0.9))
                subject.send(3)
                subject.send(4)
                scheduler.advance(by: .seconds(0.9))
                
                expect(sub.eventsWithoutSubscription) == []
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
                scheduler.advance(by: .seconds(1))
                subject.send(4)
                subject.send(5)
                subject.send(6)
                scheduler.advance(by: .seconds(1.5))
                subject.send(7)
                subject.send(8)
                subject.send(9)
                scheduler.advance(by: .seconds(1.8))
                
                expect(sub.eventsWithoutSubscription) == [.value(3), .value(6), .value(9)]
            }
            
            // MARK: 1.2 should send last value repeatedly
            it("should send the last value repeatedly") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(1)
                scheduler.advance(by: .seconds(10))
                
                expect(sub.eventsWithoutSubscription) == [.value(1)]
            }
            
            // MARK: 1.3 should send as many values as demand
            it("should send as many values as demand") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10)) { v in
                    [0, 5].contains(v) ? .max(1) : .none
                }
                
                100.times {
                    subject.send($0)
                    scheduler.advance(by: .seconds(1))
                }
                
                expect(sub.eventsWithoutSubscription.count).toEventually(equal(12))
            }
        }
        
        // MARK: - Demand
        describe("Demand") {
            
            // MARK: 2.1 should request unlimited at the beginning
            it("should request unlimited at the beginning") {
                let subject = TracingSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10)) { v in
                    [1].contains(v) ? .max(1) : .none
                }
                
                100.times {
                    subject.send($0)
                    scheduler.advance(by: .seconds(1))
                }
                expect(subject.subscription.requestDemandRecords) == [.unlimited]
                expect(subject.subscription.syncDemandRecords) == Array(repeating: .max(0), count: 100)
                
                _ = sub
            }
        }
    }
}
