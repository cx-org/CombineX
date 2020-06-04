import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class DelaySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // 1.1 should delay events
            it("should delay events") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                let pub = subject.delay(for: .seconds(1), scheduler: scheduler)

                let receiveS = TestTimeline(context: scheduler)
                let receiveV = TestTimeline(context: scheduler)
                let receiveC = TestTimeline(context: scheduler)
                
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    receiveS.record()
                    s.request(.unlimited)
                }, receiveValue: { _ in
                    receiveV.record()
                    return .none
                }, receiveCompletion: { _ in
                    receiveC.record()
                })
                
                let sendS = TestTimeline(context: scheduler)
                let sendV = TestTimeline(context: scheduler)
                let sendB = TestTimeline(context: scheduler)
                
                sendS.record()
                pub.subscribe(sub)
                
                scheduler.advance(by: .seconds(5))
                
                // wait until receiving subscription
                expect(sub.subscription).toEventuallyNot(beNil())
                
                sendV.record()
                subject.send(1)
                sendV.record()
                subject.send(2)
                
                sendB.record()
                subject.send(completion: .failure(.e0))
                
                scheduler.advance(by: .seconds(5))
                
                expect(sendS.isCloseTo(to: receiveS)) == true
                
                expect(sendV.delayed(1).isCloseTo(to: receiveV)).toEventually(beTrue())
                expect(sendB.delayed(1).isCloseTo(to: receiveC)).toEventually(beTrue())
            }
            
            // MARK: 1.2 should send events with scheduler
            it("should send events with scheduler") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                let pub = subject.delay(for: .seconds(0.1), scheduler: scheduler)
                
                var executed = (subscription: false, value: false, completion: false)
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.unlimited)
                    // Versioning: see VersioningDelaySpec
                    // expect(scheduler.isCurrent) == false
                    executed.subscription = true
                }, receiveValue: { _ in
                    expect(scheduler.base.isCurrent) == true
                    executed.value = true
                    return .none
                }, receiveCompletion: { _ in
                    expect(scheduler.base.isCurrent) == true
                    executed.completion = true
                })
                
                pub.subscribe(sub)
                
                // wait until receiving subscription
                expect(sub.subscription).toEventuallyNot(beNil())
                
                subject.send(1)
                subject.send(completion: .finished)
                
                expect(executed.subscription).toEventually(beTrue())
                expect(executed.value).toEventually(beTrue())
                expect(executed.completion).toEventually(beTrue())
            }
        }
    }
}
