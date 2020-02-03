import CXShim
import CXTestUtility
import CXUtility
import Foundation
import Nimble
import Quick

class SubscribeOnSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should subscribe on the specified queue
            it("should subscribe on the specified queue") {
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                var executed = false
                
                let upstream = TestPublisher<Int, TestError> { s in
                    let subscription = TracingSubscription(receiveRequest: { _ in
                        expect(scheduler.base.isCurrent) == true
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
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                var executed = false
                
                let upstream = TestPublisher<Int, TestError> { s in
                    let subscription = TracingSubscription(receiveRequest: { _ in
                        expect(scheduler.base.isCurrent) == true
                    })
                    s.receive(subscription: subscription)
                    let d0 = s.receive(0)
                    let d1 = s.receive(1)
                    
                    expect(d0) == .max(2)
                    expect(d1) == .max(2)
                    
                    executed = true
                }
                
                let pub = upstream.subscribe(on: scheduler)
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { _ in
                    return .max(2)
                }, receiveCompletion: { _ in
                })
                pub.subscribe(sub)
                
                expect(executed).toEventually(beTrue())
            }
            
            // MARK: 1.3 should request demand on the specified queue
            it("should request demand on the specified queue") {
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                
                let executedCount = Atom(val: 0)
                let upstream = TestPublisher<Int, TestError> { s in
                    let subscription = TracingSubscription(receiveRequest: { _ in
                        expect(scheduler.base.isCurrent) == true
                        _ = executedCount.add(1)
                    })
                    s.receive(subscription: subscription)
                }
                
                let pub = upstream.subscribe(on: scheduler)
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { _ in
                    return .max(2)
                }, receiveCompletion: { _ in
                })
                pub.subscribe(sub)
                
                expect(sub.subscription).toEventuallyNot(beNil())
                sub.subscription?.request(.max(1))
                expect(executedCount.get()).toEventually(equal(2))
            }
        }
    }
}
