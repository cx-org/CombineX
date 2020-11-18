import CXShim
import CXTestUtility
import Nimble
import Quick

class VersioningAssignSpec: QuickSpec {
    
    class Object {
        var value = 0
    }
    
    override func spec() {
        
        it("should not cancel when receiving completion") {
            let obj = Object()
            let assign = Subscribers.Assign<Object, Int>(object: obj, keyPath: \Object.value)
            var cancelled = false
            let subscription = TracingSubscription(receiveCancel: {
                cancelled = true
            })
            assign.receive(subscription: subscription)
            assign.receive(completion: .finished)
            expect(cancelled).toVersioning([
                .v11_0: beTrue(),
                .v12_0: beFalse()
            ])
        }
    }
}
