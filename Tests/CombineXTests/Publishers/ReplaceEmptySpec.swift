import CXShim
import CXTestUtility
import Nimble
import Quick

class ReplaceEmptySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should send default value if empty
            it("should send default value if empty") {
                let pub = Empty<Int, Never>().replaceEmpty(with: 1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .completion(.finished)]
            }
            
            // MARK: 1.2 should not send default value if not empty
            it("should not send default value if not empty") {
                let pub = Just(0).replaceEmpty(with: 1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.value(0), .completion(.finished)]
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.3 should throw assertion when the demand is 0
            it("should throw assertion when the demand is 0") {
                let pub = Empty<Int, Never>().replaceEmpty(with: 1)
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
