import CXShim
import Quick
import Nimble

class RemoveDuplicatesSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        it("should ignore duplicate value") {
            let subject = PassthroughSubject<Int, Never>()
            let pub = subject.removeDuplicates()
            
            let sub = TestSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            subject.send(1)
            subject.send(1)
            subject.send(2)
            subject.send(2)
            subject.send(1)
            subject.send(1)
            subject.send(completion: .finished)
            
            let events = [1, 2, 1].map { TestSubscriber<Int, Never>.Event.value($0) }
            let expected = events + [.completion(.finished)]
            expect(sub.events).to(equal(expected))
        }
    }
}
