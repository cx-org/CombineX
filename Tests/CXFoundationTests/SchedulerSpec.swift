import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class SchedulerSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: 1.1 should schedule, (we just need it to compile now, and yes! we did it! 🤣)
        it("should schedule") {
            _ = Just(1)
                .receive(on: RunLoop.main.cx)
                .receive(on: DispatchQueue.main.cx)
                .receive(on: OperationQueue.main.cx)
                .sink { _ in
                }
        }
        
        // MARK: 2.1 should clamp overflowing schedule time, instead of crash.
        it("should clamp overflowing schedule time") {
            let dts: [CXWrappers.DispatchQueue.SchedulerTimeType.Stride] = [
                .seconds(.max),
                .milliseconds(.max),
                .microseconds(.max),
                .nanoseconds(.max),
            ]
            
            expect(dts).to(beAllEqual())
            
            #if arch(x86_64) && canImport(Darwin)
            expect {
                CXWrappers.DispatchQueue.SchedulerTimeType.Stride.seconds(.infinity)
            }.to(throwAssertion())
            #endif
        }

        // MARK: 3.1 should compute time intervals correctly.
        it("should compute time intervals correctly") {
            typealias RunLoopSchedulerTimeType = CXWrappers.RunLoop.SchedulerTimeType

            let earlyDate = Date(timeIntervalSinceReferenceDate: 69)
            let lateDate = Date(timeIntervalSinceReferenceDate: 420)

            let earlyRLSTT = RunLoopSchedulerTimeType(earlyDate)
            let lateRLSTT = RunLoopSchedulerTimeType(lateDate)
            let rlDistance = earlyRLSTT.distance(to: lateRLSTT)
            expect(rlDistance) > .seconds(0)
            expect(lateRLSTT) == earlyRLSTT.advanced(by: rlDistance)

            typealias OperationQueueSchedulerTimeType = CXWrappers.OperationQueue.SchedulerTimeType

            let earlyOQSTT = OperationQueueSchedulerTimeType(earlyDate)
            let lateOQSTT = OperationQueueSchedulerTimeType(lateDate)
            let oqDistance = earlyOQSTT.distance(to: lateOQSTT)
            expect(oqDistance.timeInterval > 0).to(beTrue())
            expect(lateOQSTT) == earlyOQSTT.advanced(by: oqDistance)
        }
    }
}
