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
            
            class X: ObservableObject {
                @Published var name = 0
            }
            
            class Y: ObservableObject {}
            
            // MARK: 1.1 should publish value's change
            it("Obserable") {
                let x = X()
                let sub = makeTestSubscriber(Void.self, Never.self, .unlimited)
                x.objectWillChange.subscribe(sub)

                expect(sub.events.count).to(equal(0))
                
                x.name = 1
                x.name = 2
                
                expect(sub.events.count).to(equal(2))
            }
            
            it("should return same objectWillChange every time") {
                let x = X()
                let xPubIdentifier = ObjectIdentifier(x.objectWillChange)
                let xPubIdentifier2 = ObjectIdentifier(x.objectWillChange)
                expect(xPubIdentifier).to(equal(xPubIdentifier2))
                
                let y = Y()
                let yPubIdentifier = ObjectIdentifier(y.objectWillChange)
                let yPubIdentifier2 = ObjectIdentifier(y.objectWillChange)
                expect(yPubIdentifier).to(equal(yPubIdentifier2))
            }
        }
    }

    #endif
}
