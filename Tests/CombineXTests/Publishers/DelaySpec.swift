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
        
        afterEach {
            Resources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // 1.1 should delay events
            it("should delay events") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.delay(for: .seconds(1), scheduler: scheduler)

                let receiveS = Timeline(context: scheduler)
                let receiveV = Timeline(context: scheduler)
                let receiveC = Timeline(context: scheduler)
                
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                    receiveS.record()
                }, receiveValue: { v in
                    receiveV.record()
                    return .none
                }, receiveCompletion: { c in
                    receiveC.record()
                })
                
                let sendS = Timeline(context: scheduler)
                let sendV = Timeline(context: scheduler)
                let sendB = Timeline(context: scheduler)
                
                pub.subscribe(sub)
                sendS.record()

                subject.send(1)
                sendV.record()
                subject.send(2)
                sendV.record()
                
                subject.send(completion: .failure(.e0))
                sendB.record()
                
                scheduler.advance(by: .seconds(5))
                
                expect(sendS.isCloseTo(to: receiveS)).to(beTrue())

                expect(sendV.delayed(1).isCloseTo(to: receiveV)).toEventually(beTrue())
                expect(sendB.delayed(1).isCloseTo(to: receiveC)).toEventually(beTrue())
            }
            
            // MARK: 1.2 should not send susbcription with scheduler
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
