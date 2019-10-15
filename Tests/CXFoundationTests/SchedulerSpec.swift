import Foundation
import CXShim
import Quick
import Nimble

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
    }
}
