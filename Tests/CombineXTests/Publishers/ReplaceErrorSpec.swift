import CXShim
import CXTestUtility
import Nimble
import Quick

class ReplaceErrorSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should send default value if error
            it("should send default value if error") {
                let pub = Fail<Int, TestError>(error: .e0).replaceError(with: 1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                expect(sub.eventsWithoutSubscription) == [.value(1), .completion(.finished)]
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.2 should crash when the demand is 0
            it("should crash when the demand is 0") {
                let pub = Fail<Int, TestError>(error: .e0).replaceError(with: 1)
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
