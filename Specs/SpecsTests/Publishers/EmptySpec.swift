import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class EmptySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send completion immediately
            it("should send completion immediately") {
                let empty = Empty<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Never.self, .unlimited)
                empty.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
            // MARK: 1.2 should send nothing
            it("should send nothing") {
                let empty = Empty<Int, Never>(completeImmediately: false)
                let sub = makeCustomSubscriber(Int.self, Never.self, .unlimited)
                empty.subscribe(sub)
                expect(sub.events).to(equal([]))
            }
        }
        
        // MARK: - Equal
        describe("Equal") {
            
            // MARK: 2.1 should equal if 'completeImmediately' are the same
            it("should equal if 'completeImmediately' are the same") {
                
                let e1 = Empty<Int, Never>()
                let e2 = Empty<Int, Never>()
                let e3 = Empty<Int, Never>(completeImmediately: false)
                
                expect(e1).to(equal(e2))
                expect(e1).toNot(equal(e3))
            }
        }
    }

}
