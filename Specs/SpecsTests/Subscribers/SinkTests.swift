import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class SinkTests: XCTestCase {
    
    func testSubscribe() {
        
        let pub = PassthroughSubject<Int, Never>()
        let sink = pub.sink { (i) in
            print("sink value", i)
        }
        sink.cancel()
        
        pub.send(1)
    }
}
