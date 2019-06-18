import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class JustTests: XCTestCase {
    
    func testShouldSendValueThenSendCompletion() {
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
    
    func testShouldFreeSubWhenComplete() {
        let just = Publishers.Just(1)
        
        weak var subscriber: CustomSubscriber<Int, Never>?
        
        do {
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.max(1))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { s in
            })
            
            subscriber = sub
            just.subscribe(sub)
        }
        
        XCTAssertNil(subscriber)
    }
    
    func testShouldFreeSubAndDontFreeJustObjWhenCancel() {
        weak var pubObj: NSObject?
        weak var subObj: AnyObject?
        
        var subscription: Subscription?
        
        do {
            let pObj = NSObject()
            pubObj = pObj
            
            let pub = Publishers.Just(pObj)
            
            let sub = CustomSubscriber<NSObject, Never>(receiveSubscription: { (s) in
                subscription = s
                s.request(.max(1))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { s in
                
            })
            
            subObj = sub
            pub.subscribe(sub)
        }
        
        XCTAssertNotNil(pubObj)
        XCTAssertNil(subObj)
        
        subscription?.cancel()
        
        XCTAssertNotNil(pubObj)
        XCTAssertNil(subObj)
    }
    
    func testConcurrent() {
        let just = Publishers.Just(42)
        
        var count = 0
        
        let g = DispatchGroup()
        let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
            for _ in 0..<100 {
                g.enter()
                DispatchQueue.global().async {
                    g.leave()
                    s.request(.max(1))
                }
            }
        }, receiveValue: { v in
            count += 1
            return .none
        }, receiveCompletion: { c in
        })
        
        just.subscribe(sub)
        
        g.wait()
     
        XCTAssertEqual(count, 1)
    }
}
