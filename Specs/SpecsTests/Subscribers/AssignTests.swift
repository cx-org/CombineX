import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class AssignTests: XCTestCase {
    
    
    func testAssign() {
        
        let subject = PassthroughSubject<Int, Never>()
        
        class Obj {
            var i = 1
            
            deinit {
                print("obj deinit")
            }
        }
        
        var cancel: AnyCancellable?
        
        weak var obj: Obj?
        do {
            let o = Obj()
            cancel = subject.assign(to: \Obj.i, on: o)
            
            obj = o
        }
        
        XCTAssertNotNil(obj)
        subject.send(completion: .finished)
        XCTAssertNil(obj)
    }
}
