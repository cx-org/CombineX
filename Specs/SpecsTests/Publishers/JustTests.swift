import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class JustTests: XCTestCase {
    
    func testJust() {
        let just = Publishers.Just(1)
        
        var count = 0
        
        _ = just.sink(
            receiveCompletion: { (completion) in
                count += 1
                XCTAssertTrue(completion.isFinished)
            },
            receiveValue: { value in
                count += 1
                XCTAssertEqual(value, 1)
            }
        )
        
        XCTAssertEqual(count, 2)
    }
    
    func testCancelWhenComplete() {
        let just = Publishers.Just(1)
        
        var subscription: Subscription?
        weak var subscriber: CustomSubscriber<Int, Never>?
        
        do {
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                subscription = s
            }, receiveValue: {
                print("receive value", $0)
                return .none
            }, receiveCompletion: {
                print("receive completion", $0)
            })
            
            subscriber = sub
            just.subscribe(sub)
        }
        
        XCTAssertNotNil(subscriber)
        
        subscription?.cancel()
        
        XCTAssertNil(subscriber)
    }
    
    func testConcurrent() {
        let just = Publishers.Just(42)
        
        let g = DispatchGroup()
        
        let sub = AnySubscriber<Int, Never>.init(receiveSubscription: { (s) in
            for _ in 0..<100 {
                g.enter()
                DispatchQueue.global().async {
                    g.leave()
                    s.request(.max(1))
                }
            }
        }, receiveValue: { val in
            print("receive value", val)
            return .none
        }, receiveCompletion: { completion in
            print("receive compeltion")
        })
        
        just.subscribe(sub)
        
        g.wait()
    }
}
