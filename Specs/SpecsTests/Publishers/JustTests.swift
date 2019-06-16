import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class JustTests: XCTestCase {
    
    func testJust() {
        
        #if CombineX
        print("combine x")
        #else
        print("combine")
        #endif
    }
}
