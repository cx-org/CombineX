import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class OutputSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should only send values in the specified range
            it("should only send values in the specified range") {
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
            
            // MARK: 1.2 should send values as demand
            it("should send values as demand") {
                let sequence = Publishers.Sequence<[Int], Never>(sequence: Array(0..<100))
                
                let range = sequence.output(in: 10..<20)
                
                let subscriber = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(5))
                }, receiveValue: { v in
                    v == 10 ? .max(1) : .none
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
}
