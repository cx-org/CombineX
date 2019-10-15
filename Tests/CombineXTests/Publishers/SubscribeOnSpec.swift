import Foundation
import CXUtility
import CXShim
import Quick
import Nimble

class SubscribeOnSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should subscribe on the specified queue
            it("should subscribe on the specified queue") {
                let scheduler = TestDispatchQueueScheduler.serial()
                var executed = false
                
                let upstream = TestPublisher<Int, TestError> { (s) in
                    let subscription = TestSubscription(request: { (d) in
                        expect(scheduler.isCurrent).to(beTrue())
                        executed = true
                    })
                    s.receive(subscription: subscription)
                }
                
                let pub = upstream.subscribe(on: scheduler)
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                expect(executed).toEventually(beTrue())
            }
            
            // MARK: 1.2 should not schedule sync backpressure
            it("should not schedule sync backpressure") {
                let scheduler = TestDispatchQueueScheduler.serial()
                var executed = false
                
                let upstream = TestPublisher<Int, TestError> { (s) in
                    let subscription = TestSubscription(request: { (d) in
                        expect(scheduler.isCurrent).to(beTrue())
                    })
                    s.receive(subscription: subscription)
                    let d0 = s.receive(0)
                    let d1 = s.receive(1)
                    
                    expect(d0).to(equal(.max(2)))
                    expect(d1).to(equal(.max(2)))
                    
                    executed = true
                }
                
                let pub = upstream.subscribe(on: scheduler)
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return .max(2)
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                expect(executed).toEventually(beTrue())
            }
            
            // MARK: 1.3 should request demand on the specified queue
            it("should request demand on the specified queue") {
                let scheduler = TestDispatchQueueScheduler.serial()
                
                let executedCount = Atom(val: 0)
                let upstream = TestPublisher<Int, TestError> { (s) in
                    let subscription = TestSubscription(request: { (d) in
                        expect(scheduler.isCurrent).to(beTrue())
                        _ = executedCount.add(1)
                    })
                    s.receive(subscription: subscription)
                }
                
                let pub = upstream.subscribe(on: scheduler)
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return .max(2)
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                expect(sub.subscription).toEventuallyNot(beNil())
                sub.subscription?.request(.max(1))
                expect(executedCount.get()).toEventually(equal(2))
            }
        }
    }
}
