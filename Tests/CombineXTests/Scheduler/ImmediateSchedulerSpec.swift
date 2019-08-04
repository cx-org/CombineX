import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class ImmediateSchedulerSpec: QuickSpec {
    
    typealias Time = ImmediateScheduler.SchedulerTimeType
    typealias Stride = ImmediateScheduler.SchedulerTimeType.Stride
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: It should have a zero magnitude stride
        it("should have a zero magnitude stride") {
            
            let s0 = Stride.seconds(1)
            let s1 = Stride.nanoseconds(2)
            
            expect(s0.magnitude).to(equal(0))
            expect(s1.magnitude).to(equal(0))
        }
        
        // MARK: It should have a lazy scheduler time
        it("should have a lazy scheduler time") {
            let time = ImmediateScheduler.shared.now
            let advanced = time.advanced(by: .seconds(10))
            
            expect(advanced.distance(to: time)).to(equal(.seconds(0)))
            expect((time..<advanced).isEmpty).to(beTrue())
        }
    }
}
