import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class MapTests: XCTestCase {
    
    func testExpectMapValueFromUpstream() {
        
        let pub = PassthroughSubject<Int, CustomError>()
        
        let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
            s.request(.unlimited)
        }, receiveValue: { v in
            return .none
        }, receiveCompletion: { c in
        })
    
        pub.map { $0 * 2 }.subscribe(sub)
        
        let nums = [1, 2, 3]
        for num in nums {
            pub.send(num)
        }
        
        for (num, event) in zip(nums, sub.events) {
            XCTAssertEqual(event, .value(num * 2))
        }
    }
    
    func testShouldFreePubAndSubWhenCancel() {
        weak var pubObj: AnyObject?
        weak var closureObj: CustomObject?
        weak var subObj: AnyObject?
        
        var subscription: Subscription?
        
        do {
            let pObj = CustomObject()
            closureObj = pObj
            
            let subject = PassthroughSubject<Int, Never>()
            pubObj = subject
            
            let pub = subject.map { (v) -> Int in
                
                pObj.fn()
                return v
            }
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
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
        XCTAssertNotNil(closureObj)
        XCTAssertNotNil(subObj)
        subscription?.cancel()
        XCTAssertNil(pubObj)
        XCTAssertNil(closureObj)
        XCTAssertNil(subObj)
    }
    
    func testExpectCancelThenRequestAgain() {
        var subscription: Subscription?
        
        let subject = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
        let pub = subject.map { $0 }

        let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
            subscription = s
            s.request(.max(1))
        }, receiveValue: { v in
            print("receive value", v)
            return .none
        }, receiveCompletion: { s in
        })
        
        pub.receive(subscriber: sub)

        subscription?.cancel()
        subscription?.request(.max(1))
    }
}
