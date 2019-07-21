import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class SwitchToLatestSpec: QuickSpec {
    
    override func spec() {

        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should switch to latest publisher
            it("should switch to latest publisher") {
                let subject1 = PassthroughSubject<Int, Never>()
                let subject2 = PassthroughSubject<Int, Never>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
                
                let pub = subject.switchToLatest()
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                subject.send(subject1)
                
                subject1.send(1)
                subject1.send(2)
                subject1.send(3)
                
                subject.send(subject2)
                subject1.send(4)
                subject1.send(5)
                subject1.send(6)
                
                subject2.send(7)
                subject2.send(8)
                subject2.send(9)

                let expected = [1, 2, 3, 7, 8, 9].map { CustomEvent<Int, Never>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.2 should send as many values as demand
            #if !USE_COMBINE
            it("should send as many values as demand") {
                let subject1 = PassthroughSubject<Int, Never>()
                let subject2 = PassthroughSubject<Int, Never>()
                
                let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
                
                let pub = subject.switchToLatest()
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return [0, 10].contains(v) ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                subject.send(subject1)
                
                // FIXME: Combine will crash here, CombineX works well. I guess Combine may have a bug handling the back pressure.
                11.times { subject1.send($0) }
                
                subject.send(subject2)
                
                (11..<20).forEach { subject2.send($0) }
                
                let expected = (0..<12).map { CustomEvent<Int, Never>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            #endif
        }
    }
}
