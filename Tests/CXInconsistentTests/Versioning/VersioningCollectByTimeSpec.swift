import CXShim
import CXTestUtility
import Nimble
import Quick

class VersioningCollectByTimeSpec: QuickSpec {

    override func spec() {
        
        describe("should schedule events since iOS 13.3") {
            
            it("should schedule value") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.collect(.byTimeOrCount(scheduler, .seconds(1), 2))
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(1)
                subject.send(2)
                
                expect(sub.eventsWithoutSubscription).toVersioning([
                    .v11_0: equal([.value([1, 2])]),
                    .v11_3: equal([]),
                ])
                
                scheduler.advance(by: .zero)
                
                expect(sub.eventsWithoutSubscription) == [.value([1, 2])]
            }
        
            it("should schedule failure") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(2)))
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(1)
                subject.send(completion: .failure(.e0))
                
                expect(sub.eventsWithoutSubscription).toVersioning([
                    .v11_0: equal([.completion(.failure(.e0))]),
                    .v11_3: equal([]),
                ])
                
                scheduler.advance(by: .zero)
                
                expect(sub.eventsWithoutSubscription) == [.completion(.failure(.e0))]
            }
            
            it("should schedule finish") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.collect(.byTime(scheduler, .seconds(2)))
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(1)
                subject.send(completion: .finished)
                
                expect(sub.eventsWithoutSubscription).toVersioning([
                    .v11_0: equal([.value([1]), .completion(.finished)]),
                    .v11_3: equal([]),
                ])
                
                scheduler.advance(by: .zero)
                
                expect(sub.eventsWithoutSubscription) == [.value([1]), .completion(.finished)]
            }
        }
        
        // FIXME: Versioning: out of sync
        it("should ignore sync backpresure from scheduling sending when strategy is byTimeOrCount") {
            let subject = TracingSubject<Int, TestError>()
            let scheduler = VirtualTimeScheduler()
            let pub = subject.collect(.byTimeOrCount(scheduler, .seconds(1), 2))
            
            let sub = pub.subscribeTracingSubscriber(initialDemand: .max(2)) { v in
                if v.contains(0) { return .max(1) }
                if v.contains(2) { return .max(5) }
                return .none
            }
            
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
            
            expect(sub.eventsWithoutSubscription).toEventually(equal([
                .value([0, 1]),
                .value([2]),
                .value([3, 4]),
                .value([5]),
            ]))
        }
    }
}
