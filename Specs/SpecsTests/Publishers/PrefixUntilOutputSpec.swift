import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class PrefixUntilOutputSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Prefix
        describe("Prefix") {
            
            it("should prefix") {
                
                let pub0 = PassthroughSubject<Int, CustomError>()
                let pub1 = PassthroughSubject<Int, CustomError>()
                
                let pub = pub0.prefix(untilOutputFrom: pub1)
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                pub0.send(0)
                pub0.send(1)
                pub0.send(2)
                
//                pub1.send(completion: .finished)
                pub1.send(3)
                
                pub0.send(4)
                pub0.send(5)
                
                //                pub0.send(3)
                //                pub0.send(4)
                //                pub0.send(5)
                //
                print(sub.events)
            }
        }
    }
}
