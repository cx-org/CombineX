import CXShim
import CXTestUtility
import Nimble
import Quick

class CollectByTimeSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
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
                scheduler.advance(by: .zero)
                
                expect(sub.events) == [.value([1, 2]), .completion(.failure(.e0))]
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
                scheduler.advance(by: .zero)
                
                expect(sub.events) == [
                    .value([1, 2]),
                    .value([3, 4, 5]),
                    .completion(.finished)
                ]
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
                scheduler.advance(by: .zero)
                
                expect(sub.events) == [
                    .value([1, 2]),
                    .value([3]),
                    .value([4, 5]),
                    .value([6, 7]),
                    .value([8]),
                    .completion(.finished)
                ]
            }
            
            // MARK: 1.4 should send as many as demand when strategy is by time
            it("should send as many as demand when strategy is by time") {
                let subject = TestSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(1)))
                
                let sub = TestSubscriber<[Int], TestError>(receiveSubscription: { s in
                    s.request(.max(2))
                }, receiveValue: { v in
                    if Set(v).isDisjoint(with: [0, 5]) {
                        return .none
                    } else {
                        return .max(1)
                    }
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    if ($0 % 3) == 0 {
                        scheduler.advance(by: .seconds(1))
                    }
                    subject.send($0)
                }

                expect(sub.events.count) == 4
            }
            
            // MARK: 1.5 should always request 1 when strategy is by time
            it("should always request 1 when strategy is by time") {
                let subject = TestSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(1)))
                
                let sub = TestSubscriber<[Int], TestError>(receiveSubscription: { s in
                    s.request(.max(2))
                }, receiveValue: { v in
                    if Set(v).isDisjoint(with: [0, 5]) {
                        return .none
                    } else {
                        return .max(1)
                    }
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    if ($0 % 3) == 0 {
                        scheduler.advance(by: .seconds(1))
                    }
                    subject.send($0)
                }
                
                expect(sub.subscription).toNot(beNil())
                
                let expected0 = Array(repeating: Subscribers.Demand.max(1), count: 101)
                expect(subject.subscription.demandRecords) == expected0
                
                sub.subscription?.request(.max(2))
                
                let expected1 = Array(repeating: Subscribers.Demand.max(1), count: 102)
                expect(subject.subscription.demandRecords) == expected1
            }
        }
    }
}
