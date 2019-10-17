import Foundation
import CXShim
import Quick
import Nimble

class TimerSpec: QuickSpec {
    
    override func spec() {

        // MARK: 1.1 should not send values before connect
        it("should not send values before connect") {
            let pub = Timer.CX.publish(every: 0.1, on: RunLoop.main, in: .common)
            var dates: [Date] = []
            let cancel = pub.sink { (date) in
                dates.append(date)
            }
            
            waitUntil(timeout: 3) { (done) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    done()
                    expect(dates.count).to(equal(0))
                }
            }
            
            _ = cancel
        }
        
        // MARK: 1.2 should send values repeatedly
        it("should send values repeatedly") {
            let pub = Timer.CX.publish(every: 0.1, on: RunLoop.main, in: .common)
            var dates: [Date] = []
            let cancel = pub.sink { (date) in
                dates.append(date)
            }
            
            let connection = pub.connect()
            
            expect(dates.count).toEventually(equal(5))
            
            _ = connection
            _ = cancel
        }        
    }
}
