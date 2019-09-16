import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class AutoconnectSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Auto Connect
        describe("Auto Connect") {
            
            it("should auto connect and cancel") {
                let subject = PassthroughSubject<Int, Never>()
                let connectable = subject.makeConnectable().autoconnect()
                
                var subscription: Subscription?
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    subscription = s
                    s.request(.unlimited)
                })
                connectable.receive(subscriber: sub)
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
                
                expect(sub.events).to(equal([.value(1), .value(2), .value(3)]))
                
                subscription?.cancel()
                
                subject.send(4)
                subject.send(5)
                subject.send(6)
                
                expect(sub.events).to(equal([.value(1), .value(2), .value(3)]))
            }
        }
    }
}
