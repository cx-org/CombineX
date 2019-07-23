import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class ReceiveOnSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should receive events on the specified queue
            it("should receive events on the specified queue") {
                let subject = PassthroughSubject<Int, Never>()
                let scheduler = TestDispatchQueueScheduler.serial()
                let pub = subject.receive(on: scheduler)
                
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(100))
                    expect(scheduler.isCurrent).to(beTrue())
                }, receiveValue: { v in
                    expect(scheduler.isCurrent).to(beTrue())
                    return .none
                }, receiveCompletion: { c in
                    expect(scheduler.isCurrent).to(beTrue())
                })
                
                pub.subscribe(sub)
                
                1000.times {
                    subject.send($0)
                }
                expect(sub.events.count).toEventually(equal(100))
            }
        }
    }
}
