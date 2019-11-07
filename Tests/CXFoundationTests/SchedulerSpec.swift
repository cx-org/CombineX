import Foundation
import CXShim
import CXTestUtility
import Quick
import Nimble

class SchedulerSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
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
            
            #if !SWIFT_PACKAGE
            expect {
                CXWrappers.DispatchQueue.SchedulerTimeType.Stride.seconds(.infinity)
            }.to(throwAssertion())
            #endif
        }
    }
}
