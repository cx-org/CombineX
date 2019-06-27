import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class TryDropWhileSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should drop until predicate return false
        it("should drop until predicate return false") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: Array(0..<100))
            
            let pub = sequence.tryDrop(while: { $0 < 50 })
            
            let subscriber = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(subscriber)
            
            expect(subscriber.events.count).to(equal(51))
            for (event, value) in zip(subscriber.events.dropLast(), (50..<100)) {
                switch event {
                case .value(let i):
                    expect(i).to(equal(value))
                default:
                    fail()
                }
            }
        }
    }
}
