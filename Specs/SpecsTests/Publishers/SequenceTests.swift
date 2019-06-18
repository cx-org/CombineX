import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class SequenceTests: XCTestCase {
    
    func testExpectReceiveAsManyAsDemand() {
        
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
                XCTAssert(sub.events.count == i + 1)
            } else {
                XCTAssert(sub.events.count == i)
            }
        }
    }
    
    func testExpectFreeSubWhenCancel() {
        
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
        
        XCTAssertNotNil(seq)
        XCTAssertNotNil(subscriber)
        subscription?.cancel()
        XCTAssertNotNil(seq)
        XCTAssertNil(subscriber)
    }
}
