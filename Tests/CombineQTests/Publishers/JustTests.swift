import XCTest
@testable import CombineQ

typealias Just = CombineQ.Publishers.Just

class JustTests: XCTestCase {
    
    func testJust() {
        let just = Just(1)
        
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
