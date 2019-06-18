import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class DemandTests: XCTestCase {
    
    typealias Demand = Subscribers.Demand
    
    func testDemand() {
        
        XCTAssert(Demand.max(1) + Demand.max(2) == .max(3))
        
        XCTAssert(Demand.max(1) + Demand.unlimited == .unlimited)
        
        XCTAssert(Demand.max(1) - Demand.unlimited == .max(0))
        
        XCTAssert(Demand.unlimited - Demand.max(999)  == .unlimited)
        
        XCTAssert(Demand.max(1) * 10 == .max(10))
        
        XCTAssert(Demand.unlimited > .max(999))
        
        XCTAssert(Demand.unlimited == .unlimited)
        
        XCTAssertFalse(Demand.unlimited > .unlimited)
        XCTAssertFalse(Demand.unlimited < .unlimited)
    }
}
