import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class DelaySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // 1.1 should delay events
            it("should delay events") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.delay(for: .seconds(1), scheduler: scheduler)

                let sA = Timeline(context: scheduler)
                let vA = Timeline(context: scheduler)
                let cA = Timeline(context: scheduler)
                
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                    sA.record()
                }, receiveValue: { v in
                    vA.record()
                    return .none
                }, receiveCompletion: { c in
                    cA.record()
                })
                
                let sB = Timeline(context: scheduler)
                let vB = Timeline(context: scheduler)
                let cB = Timeline(context: scheduler)
                
                pub.subscribe(sub)
                sB.record()

                subject.send(1)
                vB.record()
                subject.send(2)
                vB.record()
                
                subject.send(completion: .failure(.e0))
                cB.record()
                
                scheduler.advance(by: .seconds(5))
                
                expect(sB.isCloseTo(to: sA)).to(beTrue())

                expect(vB.delayed(1).isCloseTo(to: vA)).toEventually(beTrue())
                expect(cB.delayed(1).isCloseTo(to: cA)).toEventually(beTrue())
            }
            
            it("should not send susbcription with scheduler") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestDispatchQueueScheduler.serial()
                let pub = subject.delay(for: .seconds(1), scheduler: scheduler)
                
                var executed = false
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                    expect(scheduler.isCurrent).to(beFalse())
                    executed = true
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                expect(executed).toEventually(beTrue())
            }
        }
    }
}
