import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class CoderSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: 1.1 should encode/decode json as expected
        it("should encode/decode json as expected") {
            struct User: Codable {
                let name: String
            }
            
            let a = User(name: "quentin")
            let json = try! JSONEncoder().cx.encode(a)
            let b = try! JSONDecoder().cx.decode(User.self, from: json)
            
            expect(b.name) == a.name
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
            
            expect(b.name) == a.name
        }
        #endif
    }
}
