import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class PassthroughSubjectSpec: QuickSpec {
    
    override func spec() {
        
        it("should send value to subscriber as many as it demand") {
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
            
            expect(sub._events.count).to(equal(4))
            
            subscription?.request(.max(5))
            
            for i in 0..<10 {
                subject.send(i)
            }
            
            expect(sub._events.count).to(equal(9))
        }
        
        it("should not send value to subscriber before it request") {
            
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
            
            XCTAssert(sub._events.isEmpty)
            
            subject.send(completion: .finished)
            
            let last = sub._events.last
            
            expect(last).notTo(beNil())
            expect(last!).to(equal(.completion(.finished)))
        }
        
        it("should not receve value after receive completion") {
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
            
            expect(sub._events.count).to(equal(1))
        }
        
        it("should work well with multi subscriber") {
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
                expect(sub._events.count).to(equal(i))
            }
            
        }
        
        it("should remove subscription when receive completion") {
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
            
            expect(subscription).toNot(beNil())
            pub.send(completion: .finished)
            expect(subscription).to(beNil())
        }
        
        it("should remove subscriber when its subscription is cancelled") {
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
            
            expect(subscriber).toNot(beNil())
            subscription?.cancel()
            expect(subscriber).to(beNil())
        }
        
        it("one subscriber should not block others") {
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
            
            expect(enters.count).to(equal(exits.count))
            expect(enters.last).to(beLessThan(exits.first!))
        }
    }
}
