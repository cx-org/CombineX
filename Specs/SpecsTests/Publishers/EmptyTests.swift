import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class EmptyTests: XCTestCase {
    
    func testEmtpy() {
        let empty = Publishers.Empty<Int, Never>()
        
        let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
//            s.request(.max(-1))
        }, receiveValue: { (v) -> Subscribers.Demand in
            print("receive value", v)
            return .none
        }, receiveCompletion: {
            print("receive completion", $0)
        })
        
        empty.subscribe(sub)
    }
}
