import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class OutputSpecs: QuickSpec {
    
    override func spec() {
        
        // MARK: It should only output elements in the specified range
        it("should only output elements in the specified range") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: Array(0..<100))
            
            let range = sequence.output(in: 10..<20)
            
            let subscriber = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                
                return .none
            }, receiveCompletion: { c in
            })
            
            range.subscribe(subscriber)
            
            let events = (10..<20).map {
                CustomSubscriber<Int, Never>.Event.value($0)
            }
            let expected = events + [.completion(.finished)]
            expect(subscriber.events).to(equal(expected))
        }
        
        // MARK: It should receive value as demand
        fit("should receive value as demand") {
            let sequence = Publishers.Sequence<[Int], Never>(sequence: Array(0..<100))
            
            let range = sequence.output(in: 10..<20)
            
            var once = false
            let subscriber = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.max(5))
            }, receiveValue: { v in
                if !once {
                    once = true
                    return .max(1)
                }
                return .none
            }, receiveCompletion: { c in
            })
            
            range.subscribe(subscriber)
            
            let expected = (10..<16).map {
                CustomSubscriber<Int, Never>.Event.value($0)
            }
            expect(subscriber.events).to(equal(expected))
        }
    }
}
