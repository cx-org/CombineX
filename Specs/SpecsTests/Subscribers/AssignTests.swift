import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class AssignTests: XCTestCase {
    
    func testShouldBindValueForKeyPathAndStopWhenComplete() {
        
        let subject = PassthroughSubject<Int, Never>()
        
        class Obj {
            var i = 1
        }
        
        let obj = Obj()
        let cancellable = subject.assign(to: \Obj.i, on: obj)
        
        subject.send(2)
        
        XCTAssert(obj.i == 2)
        
        subject.send(completion: .finished)
        subject.send(3)
        
        XCTAssert(obj.i == 2)
        
        _ = cancellable
    }
    
    func testRootShouldBeReleasedWhenComplete() {
        let subject = PassthroughSubject<Int, Never>()
        
        class Obj {
            var i = 1
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
        
        _ = cancel
    }
    
    func testRootShouldBeReleasedWhenCancel() {
        let subject = PassthroughSubject<Int, Never>()
        
        class Obj {
            var i = 1
        }
        
        var cancel: AnyCancellable?
        weak var obj: Obj?
        do {
            let o = Obj()
            cancel = subject.assign(to: \Obj.i, on: o)
            obj = o
        }
        
        XCTAssertNotNil(obj)
        cancel?.cancel()
        XCTAssertNil(obj)
        
        _ = cancel
    }
}
