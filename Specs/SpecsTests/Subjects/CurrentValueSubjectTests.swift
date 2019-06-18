import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class CurrentValueSubjectTests: XCTestCase {
    
    func testSubscriberShouldReceiveValueWhenSubscribe() {
        let subject = CurrentValueSubject<Int, CustomError>(1)
        
        var count = 0
        
        let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
            s.request(.max(1))
        }, receiveValue: { v in
            count += 1
            return .none
        }, receiveCompletion: { s in
        })
        
        subject.receive(subscriber: sub)
        
        XCTAssert(count == 1)
    }    
}
