import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class ConcatenateSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should concatenate two publishers
            it("should concatenate two publishers") {
                let p0 = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4])
                let p1 = Just(5)
                
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
            
            // MARK: 1.2 should send as many value as demand
            it("should send as many value as demand") {
                let p0 = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4, 5])
                let p1 = Publishers.Sequence<[Int], Never>(sequence: [6, 7, 8, 9, 10])
                
                let pub = Publishers.Concatenate(prefix: p0, suffix: p1)
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(7))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let events = Array(1...7).map { CustomSubscriber<Int, Never>.Event.value($0) }
                expect(sub.events).to(equal(events))
            }
        }
    }
}
