import CXShim
import CXTestUtility
import Nimble
import Quick

class SuspiciousSwitchToLatestSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: 1.1 should not crash if the child sends more events than initial demand.
        it("should not crash if the child sends more events than initial demand.") {
            let subject1 = PassthroughSubject<Int, Never>()
            
            let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
            
            let pub = subject.switchToLatest()
            let sub = TracingSubscriber<Int, Never>(receiveSubscription: { s in
                s.request(.max(10))
            }, receiveValue: { v in
                return [0, 10].contains(v) ? .max(1) : .none
            }, receiveCompletion: { _ in
            })
            pub.subscribe(sub)
            
            subject.send(subject1)
            
            (1...10).forEach(subject1.send)
            
            // FIXME: Combine will crash here. This should be a bug.
            #if !SWIFT_PACKAGE
            expect {
                subject1.send(11)
            }.toBranch(
                combine: throwAssertion(),
                cx: beVoid()
            )
            #endif
        }
    }
}
