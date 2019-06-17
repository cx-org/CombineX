import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class MapTests: XCTestCase {
    
    func testMap() {
        
        let pub = PassthroughSubject<Int, Never>().map { $0 }
        
        var subscription: Subscription?
        weak var subscriber: CustomSubscriber<Int, Never>?
        do {
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                subscription = s
                s.request(.max(1))
            }, receiveValue: { v in
                print("receive value", v)
                return .max(1)
            }, receiveCompletion: { c in
                print("receive completion", c)
            })
            
            pub.subscribe(sub)
            subscriber = sub
        }
        
        XCTAssertNotNil(subscriber)
        
        subscription?.cancel()
        
        XCTAssertNil(subscriber)
    }
}
