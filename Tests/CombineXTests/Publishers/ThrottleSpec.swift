import CXShim
import CXTestUtility
import Nimble
import Quick

class ThrottleSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            context("Latest") {
                
                // MARK: 1.1 should sent the latest value
                it("should sent the latest value") {
                    let subject = TestSubject<Int, Never>()
                    let scheduler = TestScheduler()
                    let pub = subject.throttle(for: .seconds(1), scheduler: scheduler, latest: true)
                    let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                    
                    pub.subscribe(sub)
                    
                    subject.send(1)
                    subject.send(2)
                    scheduler.advance(by: .seconds(1))
                    
                    subject.send(3)
                    subject.send(4)
                    scheduler.advance(by: .seconds(1))
                    
                    subject.send(5)
                    subject.send(6)
                    scheduler.advance(by: .seconds(2.5))
                    
                    subject.send(7)
                    
                    expect(sub.eventsWithoutSubscription) == [.value(2), .value(4), .value(6)]
                    
                    scheduler.advance(by: .seconds(0.5))
                    expect(sub.eventsWithoutSubscription) == [.value(2), .value(4), .value(6), .value(7)]
                }
                
                // MARK: 1.2 should send as many values as demand
                it("should send as many values as demand") {
                    let subject = PassthroughSubject<Int, TestError>()
                    let scheduler = TestScheduler()
                    let pub = subject.throttle(for: .seconds(1), scheduler: scheduler, latest: true)
                    let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                        s.request(.max(10))
                    }, receiveValue: { v in
                        return [0, 5].contains(v) ? .max(1) : .none
                    }, receiveCompletion: { _ in
                    })
                    pub.subscribe(sub)
                    
                    100.times {
                        subject.send($0)
                        scheduler.advance(by: .seconds(1))
                    }
                    
                    expect(sub.eventsWithoutSubscription.count).toEventually(equal(12))
                }
            }
            
            context("First") {
                
                // MARK: 1.3 should sent the latest value
                it("should sent the latest value") {
                    let subject = TestSubject<Int, Never>()
                    let scheduler = TestScheduler()
                    let pub = subject.throttle(for: .seconds(1), scheduler: scheduler, latest: false)
                    let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                    
                    pub.subscribe(sub)
                    
                    subject.send(1)
                    subject.send(2)
                    scheduler.advance(by: .seconds(1))
                    
                    subject.send(3)
                    subject.send(4)
                    scheduler.advance(by: .seconds(1))
                    
                    subject.send(5)
                    subject.send(6)
                    scheduler.advance(by: .seconds(2.5))
                    
                    subject.send(7)
                    
                    expect(sub.eventsWithoutSubscription) == [.value(1), .value(3), .value(5)]
                    
                    scheduler.advance(by: .seconds(0.5))
                    expect(sub.eventsWithoutSubscription) == [.value(1), .value(3), .value(5), .value(7)]
                }
                
                // MARK: 1.4 should send as many values as demand
                it("should send as many values as demand") {
                    let subject = PassthroughSubject<Int, TestError>()
                    let scheduler = TestScheduler()
                    let pub = subject.throttle(for: .seconds(1), scheduler: scheduler, latest: true)
                    let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                        s.request(.max(10))
                    }, receiveValue: { v in
                        return [0, 5].contains(v) ? .max(1) : .none
                    }, receiveCompletion: { _ in
                    })
                    pub.subscribe(sub)
                    
                    100.times {
                        subject.send($0)
                        scheduler.advance(by: .seconds(1))
                    }
                    
                    expect(sub.eventsWithoutSubscription.count).toEventually(equal(12))
                }
            }
        }
        
        // MARK: - Demand
        describe("Demand") {
            
            context("Latest") {
                
                // MARK: 2.1 should request unlimited at the beginning
                it("should request unlimited at the beginning") {
                    let subject = TestSubject<Int, TestError>()
                    let scheduler = TestScheduler()
                    let pub = subject.throttle(for: .seconds(1), scheduler: scheduler, latest: true)
                    let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                        s.request(.max(10))
                    }, receiveValue: { v in
                        return [1].contains(v) ? .max(1) : .none
                    }, receiveCompletion: { _ in
                    })
                    pub.subscribe(sub)
                    
                    100.times {
                        subject.send($0)
                        scheduler.advance(by: .seconds(1))
                    }
                    expect(subject.subscription.requestDemandRecords) == [.unlimited]
                    expect(subject.subscription.syncDemandRecords) == Array(repeating: .max(0), count: 100)
                }
            }
            
            context("First") {
                
                // MARK: 2.2 should request unlimited at the beginning
                it("should request unlimited at the beginning") {
                    let subject = TestSubject<Int, TestError>()
                    let scheduler = TestScheduler()
                    let pub = subject.throttle(for: .seconds(1), scheduler: scheduler, latest: false)
                    let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                        s.request(.max(10))
                    }, receiveValue: { v in
                        return [1].contains(v) ? .max(1) : .none
                    }, receiveCompletion: { _ in
                    })
                    pub.subscribe(sub)
                    
                    100.times {
                        subject.send($0)
                        scheduler.advance(by: .seconds(1))
                    }
                    expect(subject.subscription.requestDemandRecords) == [.unlimited]
                    expect(subject.subscription.syncDemandRecords) == Array(repeating: .max(0), count: 100)
                }
            }
        }
    }
}
