import CXShim
import Quick
import Nimble

class DelaySpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // 1.1 should delay events
            it("should delay events") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                let pub = subject.delay(for: .seconds(1), scheduler: scheduler)

                let receiveS = TestTimeline(context: scheduler)
                let receiveV = TestTimeline(context: scheduler)
                let receiveC = TestTimeline(context: scheduler)
                
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    receiveS.record()
                    s.request(.unlimited)
                }, receiveValue: { v in
                    receiveV.record()
                    return .none
                }, receiveCompletion: { c in
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
                
                expect(sendS.isCloseTo(to: receiveS)).to(beTrue())

                expect(sendV.delayed(1).isCloseTo(to: receiveV)).toEventually(beTrue())
                expect(sendB.delayed(1).isCloseTo(to: receiveC)).toEventually(beTrue())
            }
            
            // MARK: 1.2 should send events with scheduler
            it("should send events with scheduler") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestDispatchQueueScheduler.serial()
                let pub = subject.delay(for: .seconds(0.1), scheduler: scheduler)
                
                var executed = (subscription: false, value: false, completion: false)
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                    expect(scheduler.isCurrent).to(beTrue())
                    executed.subscription = true
                }, receiveValue: { v in
                    expect(scheduler.isCurrent).to(beTrue())
                    executed.value = true
                    return .none
                }, receiveCompletion: { c in
                    expect(scheduler.isCurrent).to(beTrue())
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
