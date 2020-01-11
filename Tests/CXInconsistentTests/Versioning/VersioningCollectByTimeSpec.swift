import CXShim
import CXTestUtility
import Nimble
import Quick

class VersioningCollectByTimeSpec: QuickSpec {

    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        describe("should schedule completion since iOS 13.3") {
        
            it("should schedule failure") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(2)))
                let sub = makeTestSubscriber([Int].self, TestError.self, .unlimited)
                
                pub.subscribe(sub)
                
                subject.send(1)
                subject.send(completion: .failure(.e0))
                
                expect(sub.events).toVersioning([
                    .v11_0: equal([.completion(.failure(.e0))]),
                    .v11_3: equal([]),
                ])
                
                scheduler.advance(by: .zero)
                
                expect(sub.events) == [.completion(.failure(.e0))]
            }
            
            it("should schedule finish") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(2)))
                let sub = makeTestSubscriber([Int].self, TestError.self, .unlimited)
                
                pub.subscribe(sub)
                
                subject.send(1)
                subject.send(completion: .finished)
                
                expect(sub.events).toVersioning([
                    .v11_0: equal([.value([1]), .completion(.finished)]),
                    .v11_3: equal([]),
                ])
                
                scheduler.advance(by: .zero)
                
                expect(sub.events) == [.value([1]), .completion(.finished)]
            }
        }
        
        it("should ignore sync backpresure from scheduling sending when strategy is byTimeOrCount") {
            let subject = TestSubject<Int, TestError>()
            let scheduler = TestScheduler()
            let pub = subject.collect(.byTimeOrCount(scheduler, .seconds(1), 2))
            
            let sub = TestSubscriber<[Int], TestError>(receiveSubscription: { s in
                s.request(.max(2))
            }, receiveValue: { v in
                if v.contains(0) { return .max(1) }
                if v.contains(2) { return .max(5) }
                return .none
            }, receiveCompletion: { _ in
            })
            
            pub.subscribe(sub)
            
            100.times {
                if $0.isMultiple(of: 3) {
                    scheduler.advance(by: .seconds(1))
                }
                subject.send($0)
            }
            
            expect(subject.subscription.syncDemandRecords).toVersioning([
                .v11_0: equal([.max(0), .max(2), .max(0), .max(0), .max(0), .max(0)]),
                .v11_3: equal([.max(0), .max(0), .max(0), .max(0), .max(0), .max(0)]),
            ])
            expect(subject.subscription.requestDemandRecords).toVersioning([
                .v11_0: equal([.max(4)]),
                .v11_3: equal([.max(4), .max(2)]),
            ])
            
            expect(sub.events).toEventually(equal([
                .value([0, 1]),
                .value([2]),
                .value([3, 4]),
                .value([5]),
            ]))
        }
    }
}
