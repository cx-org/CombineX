import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class EmptyTests: XCTestCase {
    
    func testEmtpy() {
        let empty = Publishers.Empty<Int, Never>()
        
        var count = 0
        
        let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
        }, receiveValue: { v in
            count += 1
            return .none
        }, receiveCompletion: { s in
            count += 1
        })
        
        empty.subscribe(sub)
        
        XCTAssertEqual(count, 1)
    }
    
    func testEqual() {
        let e1 = Publishers.Empty<Int, Never>()
        let e2 = Publishers.Empty<Int, Never>()
        let e3 = Publishers.Empty<Int, Never>(completeImmediately: false)
        
        XCTAssertTrue(e1 == e2)
        XCTAssertFalse(e1 == e3)
    }
}
