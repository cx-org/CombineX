import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class DispatchSchedulerSpec: QuickSpec {
    
    #if !USE_COMBINE
    typealias Time = DispatchScheduler.SchedulerTimeType
    typealias Stride = DispatchScheduler.SchedulerTimeType.Stride
    
    override func spec() {
        
        it("should have a usable time and stride") {
            expect(Stride.seconds(1)).to(equal(Stride.milliseconds(1000)))
            expect(Stride.milliseconds(1)).to(beGreaterThan(Stride.microseconds(999)))
            
            var stride = Stride.seconds(1)
            stride += Stride.nanoseconds(1)
            expect(stride).to(beGreaterThan(.seconds(1)))
            
            let scheduler = DispatchScheduler.main
            
            let now = scheduler.now
            let advanced = now.advanced(by: .seconds(10))
            let distance = now.distance(to: advanced)
            expect(distance).to(equal(.seconds(10)))
        }
        
        it("should execute action after delay") {
            let scheduler = DispatchScheduler.global()
            
            let before = DispatchTime.now()
            var after: DispatchTime?
            scheduler.schedule(after: scheduler.now.advanced(by: .seconds(0.5)), tolerance: .zero, options: nil) {
                after = DispatchTime.now()
            }
            
            expect(after).toEventually(beGreaterThan(before + 0.5))
        }
        
        it("should execute repeatedly") {
            let scheduler = DispatchScheduler.serial(label: UUID().uuidString)
            
            var count = 0
            let cancel = scheduler.schedule(after: scheduler.now, interval: .seconds(0.1), tolerance: .zero, options: nil) {
                
                if count == 5 {
                    return
                } else {
                    count += 1
                }
            }
            expect(count).toEventually(equal(5))
            cancel.cancel()
        }
        
        it("should not execute action if getting cancelled") {
            let scheduler = DispatchScheduler.global()
            
            var after: DispatchTime?
            let cancel = scheduler.schedule(after: scheduler.now, interval: .seconds(0.1), tolerance: .zero, options: nil) {
                after = DispatchTime.now()
            }
            
            cancel.cancel()
            Thread.sleep(forTimeInterval: 0.5)
            expect(after).to(beNil())
        }
    }
    #endif
}
