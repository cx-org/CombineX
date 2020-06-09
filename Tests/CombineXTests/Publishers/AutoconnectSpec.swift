import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class AutoconnectSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Auto Connect
        describe("Auto Connect") {
            
            it("should auto connect and cancel") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = subject
                    .makeConnectable()
                    .autoconnect()
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .value(2), .value(3)]
                
                sub.subscription?.cancel()
                
                subject.send(4)
                subject.send(5)
                subject.send(6)
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .value(2), .value(3)]
            }
        }
    }
}
