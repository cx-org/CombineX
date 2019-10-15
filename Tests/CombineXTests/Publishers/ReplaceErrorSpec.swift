import CXShim
import Quick
import Nimble

class ReplaceErrorSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should send default value if error
            it("should send default value if error") {
                let pub = Fail<Int, TestError>(error: .e0).replaceError(with: 1)
                let sub = makeTestSubscriber(Int.self, Never.self, .unlimited)
                pub.subscribe(sub)
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.2 should crash when the demand is 0
            it("should crash when the demand is 0") {
                let pub = Fail<Int, TestError>(error: .e0).replaceError(with: 1)
                let sub = makeTestSubscriber(Int.self, Never.self, .max(0))
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
