import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class FlatMapTests: XCTestCase {
    
    func testFlatMap() {
        let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
        
        let pub = sequence
            .flatMap {
                Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
            }
        
        let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
            s.request(.unlimited)
        }, receiveValue: { v in
            return .none
        }, receiveCompletion: { c in
        })
        
        pub.subscribe(sub)
        XCTAssert(sub.events.count == 10)
    }
}
