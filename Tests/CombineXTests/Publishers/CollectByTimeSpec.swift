import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class CollectByTimeSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should collect by time
            it("should collect by time") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(2)))
                let sub = makeTestSubscriber([Int].self, TestError.self, .unlimited)
                
                pub.subscribe(sub)
                
                subject.send(1)
                subject.send(2)
                scheduler.advance(by: .seconds(2))
                subject.send(3)
                subject.send(4)
                subject.send(5)
                scheduler.advance(by: .seconds(1))
                subject.send(completion: .failure(.e0))
                
                expect(sub.events).toEventually(equal(
                    [.value([1, 2]), .completion(.failure(.e0))]
                ))
            }
            
            // MARK: 1.2 should collect by time then send unsent values if upstream finishes
            it("should collect by time then send unsent values if upstream finishes") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(2)))
                let sub = makeTestSubscriber([Int].self, TestError.self, .unlimited)
                
                pub.subscribe(sub)
                
                subject.send(1)
                subject.send(2)
                scheduler.advance(by: .seconds(2))
                subject.send(3)
                subject.send(4)
                subject.send(5)
                scheduler.advance(by: .seconds(1))
                subject.send(completion: .finished)
                
                expect(sub.events).toEventually(equal(
                    [.value([1, 2]), .value([3, 4, 5]), .completion(.finished)]
                ))
            }
            
            // MARK: 1.3 should collect by count
            it("should collect by count") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTimeOrCount(scheduler, .seconds(2), 2))
                let sub = makeTestSubscriber([Int].self, TestError.self, .unlimited)
                
                pub.subscribe(sub)
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
                scheduler.advance(by: .seconds(2))
                subject.send(4)
                subject.send(5)
                subject.send(6)
                subject.send(7)
                subject.send(8)
                scheduler.advance(by: .seconds(2))
                subject.send(completion: .finished)
                
                expect(sub.events).toEventually(equal(
                    [.value([1, 2]), .value([3]), .value([4, 5]), .value([6, 7]), .value([8]), .completion(.finished)]
                ))

            }
            
            // MARK: 1.4 should send as many as demand when strategy is by time
            it("should send as many as demand when strategy is by time") {
                let subject = TestSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(1)))
                
                let sub = TestSubscriber<[Int], TestError>(receiveSubscription: { (s) in
                    s.request(.max(2))
                }, receiveValue: { v in
                    if Set(v).isDisjoint(with: [0, 5]) {
                        return .none
                    } else {
                        return .max(1)
                    }
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    if ($0 % 3) == 0 {
                        scheduler.advance(by: .seconds(1))
                    }
                    subject.send($0)
                }

                expect(sub.events.count).toEventually(equal(4))
            }
            
            // MARK: 1.5 should always request 1 when strategy is by time
            it("should always request 1 when strategy is by time") {
                let subject = TestSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(1)))
                
                let sub = TestSubscriber<[Int], TestError>(receiveSubscription: { (s) in
                    s.request(.max(2))
                }, receiveValue: { v in
                    if Set(v).isDisjoint(with: [0, 5]) {
                        return .none
                    } else {
                        return .max(1)
                    }
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    if ($0 % 3) == 0 {
                        scheduler.advance(by: .seconds(1))
                    }
                    subject.send($0)
                }
                
                expect(sub.subscription).toEventuallyNot(beNil())
                
                let expected0 = Array(repeating: Subscribers.Demand.max(1), count: 101)
                expect(subject.inner.demandRecords).toEventually(equal(expected0))
                
                sub.subscription?.request(.max(2))
                
                let expected1 = Array(repeating: Subscribers.Demand.max(1), count: 102)
                expect(subject.inner.demandRecords).toEventually(equal(expected1))
            }
            
            // MARK: 1.6 should ignore sync backpresure from scheduling sending when strategy is byTimeOrCount
            it("should ignore sync backpresure from scheduling sending when strategy is byTimeOrCount") {
                let subject = TestSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTimeOrCount(scheduler, .seconds(1), 2))
                
                let sub = TestSubscriber<[Int], TestError>(receiveSubscription: { (s) in
                    s.request(.max(2))
                }, receiveValue: { v in
                    if v.contains(0) { return .max(1) }
                    if v.contains(2) { return .max(5) }
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    if ($0 % 3) == 0 {
                        scheduler.advance(by: .seconds(1))
                    }
                    subject.send($0)
                }
                
                expect(subject.inner.syncDemandRecords).toEventually(equal([
                    .max(0),
                    .max(2),
                    .max(0),
                    .max(0),
                    .max(0),
                    .max(0),
                ]))
                expect(subject.inner.requestDemandRecords).toEventually(equal([
                    .max(4)
                ]))
                
                expect(sub.events).toEventually(equal([
                    .value([0, 1]),
                    .value([2]),
                    .value([3, 4]),
                    .value([5]),
                ]))
            }
        }
    }
}
