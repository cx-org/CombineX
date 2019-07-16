import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class TryRemoveDuplicatesSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should reduce values from upstream
            it("should remove duplicate values from upstream") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryRemoveDuplicates(by: ==)
                    .subscribe(sub)
                
                pub.send(1)
                pub.send(1)
                pub.send(2)
                pub.send(2)
                pub.send(3)
                pub.send(3)
                
                for (i, event) in sub.events.enumerated() {
                    switch i {
                    case 0:
                        expect(event.isValue(1)).to(beTrue())
                    case 1:
                        expect(event.isValue(2)).to(beTrue())
                    case 2:
                        expect(event.isValue(3)).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            
            // MARK: 1.2 should fail if closure throws error
            it("should fail if closure throws error") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryRemoveDuplicates(by: { (_, _) -> Bool in
                    throw CustomError.e0
                }).subscribe(sub)
                
                pub.send(1)
                pub.send(1)
                
                expect(sub.events.count).to(equal(2))
                expect(sub.events.first?.isValue(1)).to(beTrue())
                expect(sub.events.last?.error).to(matchError(CustomError.e0))
            }
        }
    }
}
