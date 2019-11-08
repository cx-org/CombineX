import CXShim
import CXTestUtility
import Quick
import Nimble

class DebounceSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should ignore the values before the due time is passed
            it("should ignore the values before the due time is passed") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                subject.send(1)
                subject.send(2)
                scheduler.advance(by: .seconds(0.9))
                subject.send(3)
                subject.send(4)
                scheduler.advance(by: .seconds(0.9))
                
                expect(sub.events).to(equal([]))
                
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
                
                expect(sub.events).to(equal([.value(3), .value(6), .value(9)]))
            }
            
            // MARK: 1.2 should send last value repeatedly
            it("should send the last value repeatedly") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                subject.send(1)
                scheduler.advance(by: .seconds(10))
                
                expect(sub.events).to(equal([.value(1)]))
            }
            
            // MARK: 1.3 should send as many values as demand
            it("should send as many values as demand") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return [0, 5].contains(v) ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                    scheduler.advance(by: .seconds(1))
                }
                
                expect(sub.events.count).toEventually(equal(12))
            }
        }
        
        
        // MARK: - Demand
        describe("Demand") {
            
            // MARK: 2.1 should request unlimited at the beginning
            it("should request unlimited at the beginning") {
                let subject = TestSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.debounce(for: .seconds(1), scheduler: scheduler)
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return [1].contains(v) ? .max(1) : .none
                }, receiveCompletion: { c in
                    
                })
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                    scheduler.advance(by: .seconds(1))
                }
                expect(subject.subscription.requestDemandRecords).to(equal([.unlimited]))
                expect(subject.subscription.syncDemandRecords).to(equal(Array(repeating: .max(0), count: 100)))
            }
        }
    }
}
