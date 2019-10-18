import CXShim
import Quick
import Nimble

class ObserableObjectSpec: QuickSpec {

    #if swift(>=5.1)
    
    typealias Published = CXShim.Published
    
    override func spec() {
        
        class X: ObservableObject {
            @Published var name = 0
        }
        
        class Y: ObservableObject {}

        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Publish
        describe("Obserable") {
            
            // MARK: 1.1 should publish value's change
            it("Observable") {
                let x = X()
                let sub = makeTestSubscriber(Void.self, Never.self, .unlimited)
                x.objectWillChange.subscribe(sub)

                expect(sub.events).to(haveCount(0))
                
                x.name = 1
                x.name = 2
                
                expect(sub.events).to(haveCount(2))
            }
        }
        
        // MARK: - Lifetime
        describe("Lifetime") {
            
            // MARK: 2.1 should return same objectWillChange every time
            it("should return same objectWillChange every time") {
                let x = X()
                let xPub1 = x.objectWillChange
                let xPub2 = x.objectWillChange
                expect(xPub1).to(beIdenticalTo(xPub2))
                
                let y = Y()
                let yPub1 = y.objectWillChange
                let yPub2 = y.objectWillChange
                expect(yPub1).to(beIdenticalTo(yPub2))
            }
            
            // MARK: 2.2 object with @Published property should hold objectWillChange
            it("object with @Published property should hold objectWillChange") {
                weak var weakPub: ObservableObjectPublisher?
                do {
                    let x = X()
                    weakPub = x.objectWillChange
                    expect(weakPub).notTo(beNil())
                }
                expect(weakPub).to(beNil())
            }
            
            // MARK: 2.3 object without @Published property should not hold objectWillChange
            it("object without @Published property should not hold objectWillChange") {
                weak var weakPub: ObservableObjectPublisher?
                do {
                    let y = Y()
                    
                    weakPub = y.objectWillChange
                    expect(weakPub).to(beNil())
                    
                    let pubId1: ObjectIdentifier
                    do {
                        pubId1 = ObjectIdentifier(y.objectWillChange)
                    }
                    let pubId2: ObjectIdentifier
                    do {
                        pubId2 = ObjectIdentifier(y.objectWillChange)
                    }
                    expect(pubId1).toNot(equal(pubId2))
                    
                    let strongPub = y.objectWillChange
                    weakPub = strongPub
                    expect(weakPub).notTo(beNil())
                }
                expect(weakPub).to(beNil())
            }
        }
    }

    #endif
}
