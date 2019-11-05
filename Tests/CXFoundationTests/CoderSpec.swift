import Foundation
import CXShim
import CXTestUtility
import Quick
import Nimble

class CoderSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: 1.1 should encode/decode json as expected
        it("should encode/decode json as expected") {
            struct User: Codable {
                let name: String
            }
            
            let a = User(name: "quentin")
            let json = try! JSONEncoder().cx.encode(a)
            let b = try! JSONDecoder().cx.decode(User.self, from: json)
            
            expect(b.name).to(equal(a.name))
        }
        
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        // MARK: 1.2 should encode/decode plist as expected
        it("should encode/decode plist as expected") {
            struct User: Codable {
                let name: String
            }
            
            let a = User(name: "quentin")
            let json = try! PropertyListEncoder().cx.encode(a)
            let b = try! PropertyListDecoder().cx.decode(User.self, from: json)
            
            expect(b.name).to(equal(a.name))
        }
        #endif
    }
}
