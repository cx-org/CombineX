import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class RemoveDuplicatesSpec: QuickSpec {
    
    override func spec() {
        
        it("should ignore duplicate value") {
            let subject = PassthroughSubject<Int, Never>()
            let pub = subject.removeDuplicates()
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
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
            
            let events = [1, 2, 1].map { CustomSubscriber<Int, Never>.Event.value($0) }
            let expected = events + [.completion(.finished)]
            expect(sub.events).to(equal(expected))
        }
    }
}
