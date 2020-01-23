import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class ReceiveOnSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should receive events on the specified queue
            it("should receive events on the specified queue") {
                let subject = PassthroughSubject<Int, Never>()
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                let pub = subject.receive(on: scheduler)
                
                var received = (
                    subscription: false,
                    value: false,
                    completion: false
                )
                
                let sub = TracingSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(100))
                    received.subscription = true
                    // Versioning: see VersioningReceiveOnSpec
                    // expect(scheduler.isCurrent) == false
                }, receiveValue: { _ in
                    received.value = true
                    expect(scheduler.base.isCurrent) == true
                    return .none
                }, receiveCompletion: { _ in
                    received.completion = true
                    expect(scheduler.base.isCurrent) == true
                })
                
                pub.subscribe(sub)
                
                // Versioning: see VersioningReceiveOnSpec
                expect(sub.subscription).toEventuallyNot(beNil())
                
                1000.times {
                    subject.send($0)
                }
                subject.send(completion: .finished)

                expect(
                    [
                        received.subscription,
                        received.value,
                        received.completion
                    ]
                ).toEventually(equal([true, true, true]))
            }
            
            // MARK: 1.2 should send values as many as demand
            it("should send values as many as demand") {
                let subject = PassthroughSubject<Int, Never>()
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                let pub = subject.receive(on: scheduler)
                
                let sub = TracingSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { _ in
                    // FIXME: Apple's Combine doesn't seems to strictly support sync backpressure.
                    return .none
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                expect(sub.subscription).toEventuallyNot(beNil())
                
                100.times {
                    subject.send($0)
                }
                
                expect(sub.eventsWithoutSubscription.count).toEventually(equal(10))
            }
        }
    }
}
