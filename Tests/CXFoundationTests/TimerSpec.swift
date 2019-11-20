import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class TimerSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }

        // MARK: 1.1 should not send values before connect
        it("should not send values before connect") {
            let pub = CXWrappers.Timer.publish(every: 0.1, on: RunLoop.main, in: .common)
            let sub = makeTestSubscriber(Date.self, Never.self, .unlimited)
            pub.subscribe(sub)
            
            waitUntil(timeout: 3) { done in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    done()
                    expect(sub.events).to(beEmpty())
                }
            }
        }
        
        // MARK: 1.2 should send values repeatedly
        it("should send values repeatedly") {
            let pub = CXWrappers.Timer.publish(every: 0.1, on: RunLoop.main, in: .common)
            let sub = makeTestSubscriber(Date.self, Never.self, .unlimited)
            pub.subscribe(sub)
            
            let connection = pub.connect()
            
            expect(sub.events).toEventually(haveCount(5))
            
            _ = connection
        }        
    }
}
