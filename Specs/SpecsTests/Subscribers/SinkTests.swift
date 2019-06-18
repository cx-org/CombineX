import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class SinkTests: XCTestCase {
    
    func testShouldReceiveValuesAndCompletion() {
        let pub = PassthroughSubject<Int, Never>()
        
        var valueCount = 0
        var completionCount = 0
        
        let sink = Subscribers.Sink<PassthroughSubject<Int, Never>>(receiveCompletion: { (c) in
            completionCount += 1
        }, receiveValue: { v in
            valueCount += 1
        })
        
        pub.subscribe(sink)
        
        pub.send(1)
        pub.send(1)
        pub.send(completion: .finished)
        pub.send(1)
        pub.send(completion: .finished)
        
        XCTAssert(valueCount == 2)
        XCTAssert(completionCount == 1)
    }
    
    func testSubscriptionShouldBeReleaseWhenReceiveCompletion() {
        
        let sink = Subscribers.Sink<Publishers.Just<Int>>(
            receiveCompletion: { c in
            },
            receiveValue: { v in
            }
        )
        
        weak var subscription: CustomSubscription?
        
        do {
            let s = CustomSubscription(
                request: { (demand) in
                },
                cancel: {
                }
            )
            
            sink.receive(subscription: s)
            subscription = s
        }
        
        XCTAssertNotNil(subscription)
        sink.receive(completion: .finished)
        XCTAssertNil(subscription)
    }
}
