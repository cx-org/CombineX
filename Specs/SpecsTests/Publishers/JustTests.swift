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
}
