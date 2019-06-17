import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class PassthroughSubjectTests: XCTestCase {
    
    func testSubject() {
        
        weak var subscription: AnyObject?
        
        let sub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
            s.request(.max(1))
            
            subscription = s as AnyObject
        }, receiveValue: {
            print("receive value", $0)
            return .none
        }, receiveCompletion: {
            print("receive completion", $0)
        })
        
        let pub = PassthroughSubject<Int, Never>()
        pub.subscribe(sub)
        
        pub.send(1)
        
        XCTAssertNotNil(subscription)
        pub.send(completion: .finished)
        XCTAssertNil(subscription)
        
        pub.send(1)
    }
}
