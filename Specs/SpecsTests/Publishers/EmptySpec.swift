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
                let empty = Publishers.Empty<Int, Never>()

                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                empty.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
        }
        
        // MARK: - Equal
        describe("Equal") {
            
            // MARK: 2.1 should equal if 'immediately' are the same
            it("should equal if 'immediately' are the same") {
                
                let e1 = Publishers.Empty<Int, Never>()
                let e2 = Publishers.Empty<Int, Never>()
                let e3 = Publishers.Empty<Int, Never>(completeImmediately: false)
                
                expect(e1).to(equal(e2))
                expect(e1).toNot(equal(e3))
            }
        }
    }

}
