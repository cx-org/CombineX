import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class VersioningReceiveOnSpec: QuickSpec {

    override func spec() {
        
        it("should not schedule subscription since iOS 13.3") {
            let subject = PassthroughSubject<Int, Never>()
            let scheduler = DispatchQueue(label: UUID().uuidString).cx
            let pub = subject.receive(on: scheduler)
            let sub = TracingSubscriber<Int, Never>(receiveSubscription: { s in
                expect(scheduler.base.isCurrent).toVersioning([
                    .v11_0: beTrue(),
                    .v11_3: beFalse(),
                ])
            })
            pub.subscribe(sub)

            expect(sub.subscription).toVersioning([
                .v11_0: beNil(),
                .v11_3: beNotNil(),
            ])
            expect(sub.subscription).toEventuallyNot(beNil())
        }
    }
}
