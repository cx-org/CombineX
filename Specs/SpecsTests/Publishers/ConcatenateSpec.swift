import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class ConcatenateSpec: QuickSpec {
    
    override func spec() {
        
        it("should concatenate two publishers") {
            let p0 = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4])
            let p1 = Publishers.Just(5)
            
            let pub = Publishers.Concatenate(prefix: p0, suffix: p1)
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            let events = Array(1...5).map { CustomSubscriber<Int, Never>.Event.value($0) }
            let expected = events + [.completion(.finished)]
            expect(sub.events).to(equal(expected))
        }
    }
}
