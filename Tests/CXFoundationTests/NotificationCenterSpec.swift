import Foundation
import CXShim
import Quick
import Nimble

class NotificationCenterSpec: QuickSpec {
    
    override func spec() {

        // MARK: 1.1 should send as many notications as demand
        it("should send as many notications as demand") {
            let name = Notification.Name(rawValue: UUID().uuidString)
            let pub = NotificationCenter.default.cx.publisher(for: name)
            
            var notifications: [Notification] = []
            
            let sink = pub.sink { (n) in
                notifications.append(n)
            }
            
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            
            expect(notifications.count).toEventually(equal(3))
            
            _ = sink
        }
        
        // MARK: 1.2 should stop sending values after cancel
        it("should stop sending values after cancel") {
            let name = Notification.Name(rawValue: UUID().uuidString)
            let pub = NotificationCenter.default.cx.publisher(for: name)
            
            var notifications: [Notification] = []
            
            let sink = pub.sink { (n) in
                notifications.append(n)
            }
            sink.cancel()
            
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            NotificationCenter.default.post(name: name, object: nil)
            
            expect(notifications.count).toEventually(equal(0))
        }
    }
}
