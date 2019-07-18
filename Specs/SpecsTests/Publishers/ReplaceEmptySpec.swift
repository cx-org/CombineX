import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class ReplaceEmptySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should send default value if empty
            it("should send default value if empty") {
                let pub = Empty<Int, Never>().replaceEmpty(with: 1)
                let sub = makeCustomSubscriber(Int.self, Never.self, .unlimited)
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
            
            // MARK: 1.2 should not send default value if not empty
            it("should not send default value if not empty") {
                let pub = Just(0).replaceEmpty(with: 1)
                let sub = makeCustomSubscriber(Int.self, Never.self, .unlimited)
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.value(0), .completion(.finished)]))
            }
            
            #if !SWIFT_PACAKGE
            // MARK: 1.3 should throw assertion when the demand is 0
            it("should throw assertion when the demand is 0") {
                let pub = Empty<Int, Never>().replaceEmpty(with: 1)
                let sub = makeCustomSubscriber(Int.self, Never.self, .max(0))
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
