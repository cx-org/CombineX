import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class SequenceSpec: QuickSpec {
    
    override func spec() {
        
        it("should recevie value as many as demand") {
            let nums = [1, 2, 3, 4, 5]
            let pub = Publishers.Sequence<[Int], Never>(sequence: nums)
            
            var subs: [CustomSubscriber<Int, Never>] = []
            
            for i in nums {
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(i))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                subs.append(sub)
                
                pub.subscribe(sub)
                
                if i == 5 {
                    expect(sub._events.count).to(equal(i + 1))
                } else {
                    expect(sub._events.count).to(equal(i))
                }
            }
        }
        
        it("should release sub when cancel") {
            class Seq: Sequence, IteratorProtocol {
                
                func next() -> Int? {
                    return 1
                }
            }
            
            weak var seq: Seq?
            weak var subscriber: CustomSubscriber<Int, Never>?
            var subscription: Subscription?
            
            do {
                let s = Seq()
                seq = s
                let pub = Publishers.Sequence<Seq, Never>(sequence: s)
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                subscriber = sub
                pub.subscribe(sub)
            }
            
            expect(seq).toNot(beNil())
            expect(subscriber).toNot(beNil())
            subscription?.cancel()
            expect(seq).toNot(beNil())
            expect(subscriber).to(beNil())
        }
    }

}
