import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class BreakPointSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Break Point
        xdescribe("Break Point", flags: [:]) {
            
            it("should raise a sigtrap") {
                let pub = Just(1)
                let sink = pub.breakpoint(receiveOutput: { _ in
                        true
                    })
                    .sink { (_) in
                    }
                _ = sink
            }
        }
    }
}
