import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CountSpec: QuickSpec {
    
    override func spec() {

        // MARK: It should count correctly
        it("should count correctly") {
            
            let sequence = Publishers.Sequence<[Int], Never>(sequence: Array(0..<100))
            let count: Publishers.Count<Publishers.Sequence<[Int], Never>> = sequence.count()
            
            let subscriber = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.max(1))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })

            count.subscribe(subscriber)
            
            let events = [CustomSubscriber<Int, Never>.Event.value(100)]
            let expected = events + [.completion(.finished)]
            expect(subscriber.events).to(equal(expected))
        }
    }
}
