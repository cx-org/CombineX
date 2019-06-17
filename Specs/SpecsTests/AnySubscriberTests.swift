import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class AnySubscriberTests: XCTestCase {
    
    func testSubjectBehavior() {
    
        let subject = PassthroughSubject<Int, Error>()
        let subscriber = AnySubscriber(subject)
        
        let subscription = CustomSubscription(request: { (demand) in
            XCTAssertEqual(demand, Subscribers.Demand.unlimited)
        }, cancel: {
        })
        
        let pub = AnyPublisher<Int, Error> { (s) in
            s.receive(subscription: subscription)
            XCTAssertEqual(s.receive(1), .none)
        }
        
        pub.subscribe(subscriber)
    }
}
