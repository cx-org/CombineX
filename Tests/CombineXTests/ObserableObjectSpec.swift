import CXShim
import Quick
import Nimble

class ObserableObjectSpec: QuickSpec {

    #if swift(>=5.1)
    
    typealias Published = CXShim.Published
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Publish
        describe("Obserable") {
            
            // MARK: 1.1 should publish value's change
            it("Obserable") {
                class X: ObservableObject {
                    @Published var name = 0
                }
                let x = X()
                let sub = makeTestSubscriber(Void.self, Never.self, .unlimited)
                x.objectWillChange.subscribe(sub)

                expect(sub.events.count).to(equal(0))
                
                x.name = 1
                x.name = 2
                
                expect(sub.events.count).to(equal(2))
            }
        }
    }

    #endif
}
