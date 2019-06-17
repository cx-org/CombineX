import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class AnyCancellableTests: XCTestCase {
    
    func testShouldFreeClosureWhenCancel() {
    
        var cancel: Cancellable?
        weak var obj: CustomObject?
        
        do {
            let o = CustomObject()
            
            cancel = AnyCancellable {
                o.fn()
            }
            
            obj = o
        }

        XCTAssertNotNil(obj)
        
        cancel?.cancel()
        
        XCTAssertNil(obj)
    }
    
    func testShouldCancelWhenDeinit() {
        var b = true
        
        do {
            _ = AnyCancellable {
                b = false
            }
        }
        
        XCTAssertFalse(b)
    }
}
