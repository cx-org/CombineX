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
    
    func testSubscription() {
        
        let sink = Subscribers.Sink<Publishers.Just<Int>>.init(receiveCompletion: {
            print("receive completion", $0)
        }, receiveValue: {
            print("receive value", $0)
        })
        
        weak var subscription: CustomSubscription?
        
        do {
            let s = CustomSubscription(request: { (demand) in
                print("request demand", demand)
            }, cancel: {
                print("cancel")
            })
            
            sink.receive(subscription: s)
            
            subscription = s
        }
        
        XCTAssertNotNil(subscription)
        sink.receive(completion: .finished)
        XCTAssertNil(subscription)
    }
}
