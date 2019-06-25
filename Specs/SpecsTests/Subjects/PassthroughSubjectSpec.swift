import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class PassthroughSubjectSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should send value to subscriber as many as it demand
        it("should send value to subscriber as many as it demand") {
            let subject = PassthroughSubject<Int, CustomError>()
            
            var subscription: Subscription?
            var once = false
            
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                subscription = s
                s.request(.max(2))
            }, receiveValue: { v in
                if once {
                    return .none
                } else {
                    once = true
                    return .max(2)
                }
            }, receiveCompletion: { s in
                
            })
            
            subject.receive(subscriber: sub)
            
            for i in 0..<10 {
                subject.send(i)
            }
            
            expect(sub.events.count).to(equal(4))
            
            subscription?.request(.max(5))
            
            for i in 0..<10 {
                subject.send(i)
            }
            
            expect(sub.events.count).to(equal(9))
        }
        
        // MARK: It should not send value to subscriber before it request
        it("should not send value to subscriber before it request") {
            
            let subject = PassthroughSubject<Int, CustomError>()
            
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
            }, receiveValue: { v in
                fail("Should not receive value")
                return .none
            }, receiveCompletion: { s in
            })
            
            subject.receive(subscriber: sub)
            subject.send(1)
            subject.send(1)
            
            expect(sub.events).to(beEmpty())
            
            subject.send(completion: .finished)
            
            let last = sub.events.last
            
            expect(last).notTo(beNil())
            expect(last!).to(equal(.completion(.finished)))
        }
        
        // MARK: It should not receve value after receive completion
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
            
            expect(sub.events.count).to(equal(1))
        }
        
        // MARK: It should work well with multi subscriber
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
                expect(sub.events.count).to(equal(i))
            }
        }
        
        // MARK: It should remove subscription when receive completion
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
        
        // MARK: It should remove subscriber when its subscription is cancelled
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
        
        // MARK: It should work well when send concurrently
        xit("should work well when send concurrently") {
            let subject = PassthroughSubject<Int, Never>()
  
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.max(5))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            subject.subscribe(sub)
            
            let g = DispatchGroup()
            100.times { i in
                DispatchQueue.global().async(group: g) {
                    subject.send(i)
                }
            }
            
            g.wait()
            
            // FIXME: Apple's combine seems to be thread-unsafe?
            expect(sub.events.count).to(equal(5))
        }
        
        // MARK: It should block when receving value if `PassthroughSubject` is thread-safe
        xit("should block when receving value if PassthroughSubject is thread-safe") {
            let g = DispatchGroup()
            
            let pub = PassthroughSubject<Int, Never>()
            
            var enters: [Date?] = [nil, nil, nil]
            var exits: [Date?] = [nil, nil, nil]

            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                Thread.sleep(forTimeInterval: 1)
                return .none
            }, receiveCompletion: { s in
            })
            
            pub.subscribe(sub)
            
            for i in 0..<3 {
                DispatchQueue.global().async(group: g) {
                    enters[i] = Date()
                    pub.send(i)
                    exits[i] = Date()
                }
            }
            
            g.wait()
            
            // FIXME: Apple's combine seems to be thread-unsafe? So the concurrent sending doesn't block each other?
            print(enters)
            print(exits)
        }
    }
}
