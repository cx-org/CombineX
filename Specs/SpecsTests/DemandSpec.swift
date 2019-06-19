import Quick
import Nimble

#if CombineX
import CombineX
#else
import Combine
#endif

class DemandSpec: QuickSpec {
    
    typealias Demand = Subscribers.Demand
    
    override func spec() {
        
        it("should calculate as expect") {
            expect(Demand.max(1) + Demand.max(2)).to(equal(.max(3)))
            expect(Demand.max(1) + Demand.unlimited).to(equal(.unlimited))
            
            expect(Demand.max(1) - Demand.unlimited).to(equal(.max(0)))
            expect(Demand.unlimited - Demand.max(999)).to(equal(.unlimited))
            
            expect(Demand.max(1) * 10).to(equal(.max(10)))
            
            expect(Demand.unlimited).to(beGreaterThan(.max(999)))
            expect(Demand.unlimited).to(equal(.unlimited))
            expect(Demand.unlimited).toNot(beLessThan(.unlimited))
            expect(Demand.unlimited).toNot(beGreaterThan(.unlimited))
        }
    }
}
