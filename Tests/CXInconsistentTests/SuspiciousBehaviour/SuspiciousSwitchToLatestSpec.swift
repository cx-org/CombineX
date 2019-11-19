import CXShim
import CXTestUtility
import Nimble
import Quick

class SuspiciousSwitchToLatestSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: 1.1 should not crash if the child sends more events than initial demand.
        it("should not crash if the child sends more events than initial demand.") {
            let subject1 = PassthroughSubject<Int, Never>()
            
            let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
            
            let pub = subject.switchToLatest()
            let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
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
                combine: beVoid(),
                cx: throwAssertion())
            #endif
        }
        
        // MARK: 1.2 should finish when the last child finish
        it("should finish when the last child finish") {
            let subject1 = PassthroughSubject<Int, TestError>()
            let subject2 = PassthroughSubject<Int, TestError>()
            
            let subject = PassthroughSubject<PassthroughSubject<Int, TestError>, TestError>()
            let pub = subject.switchToLatest()
            let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
            pub.subscribe(sub)
            
            subject.send(subject1)
            subject1.send(completion: .finished)
            expect(sub.events) == []
            
            subject.send(subject2)
            expect(sub.events) == []
            
            subject.send(completion: .finished)
            expect(sub.events) == []
            
            // FIXME: Combine won't get any event when the last child finish.
            subject2.send(completion: .finished)
            expect(sub.events).toBranch(
                combine: beEmpty(),
                cx: equal([.completion(.finished)]))
        }
        
        // MARK: 1.3 should send as many values as demand
        it("should send as many values as demand") {
            let subject1 = PassthroughSubject<Int, Never>()
            let subject2 = PassthroughSubject<Int, Never>()
            
            let subject = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
            
            let pub = subject.switchToLatest()
            let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                s.request(.max(10))
            }, receiveValue: { v in
                return [1, 11].contains(v) ? .max(1) : .none
            }, receiveCompletion: { _ in
            })
            pub.subscribe(sub)
            
            subject.send(subject1)
            
            (1...10).forEach(subject1.send)
            
            subject.send(subject2)
            
            (11...20).forEach(subject2.send)
            
            // FIXME: Combine will get only 10 values (demand 12).
            expect(sub.events).toBranch(
                combine: haveCount(10),
                cx: haveCount(12))
        }
    }
}
