import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class RepleaceErrorSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should send default value if error
            it("should send default value if error") {
                
                let pub = Publishers.Fail<Int, CustomError>(error: .e0)
                
                let sub = makeCustomSubscriber(Int.self, Never.self, .unlimited)
                pub.replaceError(with: 1).subscribe(sub)
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
            
            #if !SWIFT_PACAKGE
            // MARK: 1.2 should crash when the demand is 0
            it("should crash when the demand is 0") {
                let pub = Publishers.Fail<Int, CustomError>(error: .e0).replaceError(with: 1)
                
                let sub = makeCustomSubscriber(Int.self, Never.self, .max(0))
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
