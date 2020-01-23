import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

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
                let sub = TracingSubscriber<Int, Never>(receiveSubscription: { s in
                    subscription = s
                    s.request(.unlimited)
                })
                connectable.receive(subscriber: sub)
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
                
                expect(sub.events) == [.value(1), .value(2), .value(3)]
                
                subscription?.cancel()
                
                subject.send(4)
                subject.send(5)
                subject.send(6)
                
                expect(sub.events) == [.value(1), .value(2), .value(3)]
            }
        }
    }
}
