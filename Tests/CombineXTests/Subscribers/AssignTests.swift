import XCTest
@testable import CombineX

typealias Assign = CombineX.Subscribers.Assign

class AssignTests: XCTestCase {
    
    func testAssign() {
        #if CombineQ
        print("combineQ")
        #else
        print("combine")
        #endif
    }
}
