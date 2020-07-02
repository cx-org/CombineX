import CXShim
import CXTestUtility
import CXUtility
import Foundation
import Nimble
import Quick

class SubscribeOnSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should subscribe on the specified queue
            it("should subscribe on the specified queue") {
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                var executed = false
                
                let upstream = AnyPublisher<Int, TestError> { s in
                    let subscription = TracingSubscription(receiveRequest: { _ in
                        expect(scheduler.base.isCurrent) == true
                        executed = true
                    })
                    s.receive(subscription: subscription)
                }
                
                let pub = upstream.subscribe(on: scheduler)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(executed).toEventually(beTrue())
                
                _ = sub
            }
            
            // MARK: 1.2 should not schedule sync backpressure
            it("should not schedule sync backpressure") {
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                var executed = false
                
                let upstream = AnyPublisher<Int, TestError> { s in
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
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10), subsequentDemand: .max(2))
                
                expect(executed).toEventually(beTrue())
                
                _ = sub
            }
            
            // MARK: 1.3 should request demand on the specified queue
            it("should request demand on the specified queue") {
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                
                let executedCount = LockedAtomic(0)
                let upstream = AnyPublisher<Int, TestError> { s in
                    let subscription = TracingSubscription(receiveRequest: { _ in
                        expect(scheduler.base.isCurrent) == true
                        _ = executedCount.loadThenWrappingIncrement()
                    })
                    s.receive(subscription: subscription)
                }
                
                let pub = upstream.subscribe(on: scheduler)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10), subsequentDemand: .max(2))
                
                expect(sub.subscription).toEventuallyNot(beNil())
                sub.subscription?.request(.max(1))
                expect(executedCount.load()).toEventually(equal(2))
            }
        }
    }
}
