import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class ShareSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Relay
        describe("Relay") {
            
            it("share") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.map { i -> Int in
                    Swift.print("map", i)
                    return i
                }.share()

                let sinkA = pub.sink { (v) in
                    Swift.print("sink a", v)
                }

                let sinkB = pub.sink { (v) in
                    Swift.print("sink b", v)
                }
                
                subject.send(1)
                subject.send(2)
                subject.send(3)
            }
        }
    }
}
