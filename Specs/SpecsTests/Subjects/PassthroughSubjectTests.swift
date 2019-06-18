import XCTest

#if CombineX
import CombineX
#else
import Combine
#endif

class PassthroughSubjectTests: XCTestCase {
    
    func testSubscriberShouldReceiveValueAsManyAsDemand() {
        let subject = PassthroughSubject<Int, CustomError>()
        
        var subscription: Subscription?
        var asked = false
        
        let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
            subscription = s
            s.request(.max(2))
        }, receiveValue: { v in
            if asked {
                return .none
            } else {
                asked = true
                return .max(2)
            }
        }, receiveCompletion: { s in
            
        })
        
        subject.receive(subscriber: sub)
        
        for i in 0..<10 {
            subject.send(i)
        }
        
        XCTAssertEqual(sub.events.count, 4)
        
        subscription?.request(.max(5))
        
        for i in 0..<10 {
            subject.send(i)
        }
        
        XCTAssertEqual(sub.events.count, 9
        )
    }
    
    func testSubscriberShouldNotReceiveValueBeforeRequestDemand() {
        let subject = PassthroughSubject<Int, CustomError>()
        
        let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
        }, receiveValue: { v in
            XCTFail("Should not receive value")
            return .none
        }, receiveCompletion: { s in
        })
        
        subject.receive(subscriber: sub)
        subject.send(1)
        subject.send(1)
        
        XCTAssert(sub.events.isEmpty)
        
        subject.send(completion: .finished)

        let last = sub.events.last
        XCTAssertNotNil(last)
        XCTAssertEqual(last!, .completion(.finished))
    }
    
    func testReceiveCompletion() {
        let subject = PassthroughSubject<Int, Error>()
        
        let sub = CustomSubscriber<Int, Error>(receiveSubscription: { s in
            s.request(.unlimited)
        }, receiveValue: { v in
            return .none
        }, receiveCompletion: { c in
        })
        
        subject.receive(subscriber: sub)
        
        subject.send(completion: .finished)
        
        for i in 0..<10 {
            subject.send(i)
        }

        XCTAssertEqual(sub.events.count, 1)
    }

    func testReceiveMultipleSubscriber() {
        let subject = PassthroughSubject<Int, Error>()
        
        var subs: [CustomSubscriber<Int, Error>] = []
        let nums = [0, 0, 0, 1, 2, 3]
        
        for i in nums {
            let sub = CustomSubscriber<Int, Error>(receiveSubscription: { s in
                s.request(.max(i))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            subject.receive(subscriber: sub)
            
            subs.append(sub)
        }
        
        for i in 0..<10 {
            subject.send(i)
        }
        
        for (i, sub) in zip(nums, subs) {
            XCTAssertEqual(sub.events.count, i)
        }
    }
    
    func testShouldRemoveSubscriptionWhenFinished() {
        let pub = PassthroughSubject<Int, Never>()
        
        weak var subscription: AnyObject?
        
        let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
            s.request(.max(1))
            subscription = s as AnyObject
        }, receiveValue: { v in
            return .none
        }, receiveCompletion: { s in
        })
        
        pub.subscribe(sub)
        
        XCTAssertNotNil(subscription)
        pub.send(completion: .finished)
        XCTAssertNil(subscription)
    }
    
    func testCancel() {
        let pub = PassthroughSubject<Int, Never>()
    
        var subscription: Subscription?
        weak var subscriber: CustomSubscriber<Int, Never>?
        
        do {
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.max(1))
                subscription = s
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { s in
            })
            
            pub.subscribe(sub)
            
            subscriber = sub
        }
        
        XCTAssertNotNil(subscriber)
        subscription?.cancel()
        XCTAssertNil(subscriber)
    }
    
    func testOneSubscriberShouldNotBlockOthers() {
        let g = DispatchGroup()
        
        let pub = PassthroughSubject<Int, Never>()
        
        let syncQ = DispatchQueue(label: UUID().uuidString)
        var enters: [Date] = []
        var exits: [Date] = []
        
        let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
            s.request(.unlimited)
        }, receiveValue: { v in
            syncQ.async(group: g) {
                enters.append(Date())
            }
            Thread.sleep(forTimeInterval: 1)
            
            syncQ.async(group: g) {
                exits.append(Date())
            }
            return .none
        }, receiveCompletion: { s in
        })
        pub.subscribe(sub)
        
        for i in 0..<3 {
            DispatchQueue.global().async(group: g) {
                pub.send(i)
            }
        }
   
        g.wait()
        
        XCTAssert(enters.count == exits.count)
        XCTAssert(enters.last! < exits.first!)
    }
}
