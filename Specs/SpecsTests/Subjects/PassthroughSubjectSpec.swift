import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class PassthroughSubjectSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {

            // MARK: 1.1 should send as many values as the subscriber's demand
            it("should send as many values as the subscriber's demand") {
                typealias Sub = CustomSubscriber<Int, CustomError>
                
                let subject = PassthroughSubject<Int, CustomError>()
                
                var subscription: Subscription?
                
                let sub = Sub(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    return v == 0 ? .max(1) : .none
                }, receiveCompletion: { s in
                })
                
                subject.subscribe(sub)
                
                for i in 0..<10 {
                    subject.send(i)
                }
                
                expect(sub.events.count).to(equal(2))
                
                subscription?.request(.max(5))
                
                for i in 10..<20 {
                    subject.send(i)
                }
                
                expect(sub.events.count).to(equal(7))
            }
            
            // MARK: 1.2 should not send values to subscribers after sending completion
            it("should not send values to subscribers after sending completion") {
                typealias Sub = CustomSubscriber<Int, CustomError>
                
                let subject = PassthroughSubject<Int, CustomError>()
                
                let sub = Sub(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                subject.subscribe(sub)
                
                subject.send(completion: .finished)
                
                for i in 0..<10 {
                    subject.send(i)
                }
                
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
            // MARK: 1.3 should not send completion to subscribers after sending completion
            it("should not send completion to subscribers after sending completion") {
                typealias Sub = CustomSubscriber<Int, CustomError>
                
                let subject = PassthroughSubject<Int, CustomError>()
                
                let sub = Sub(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                subject.subscribe(sub)
                
                subject.send(completion: .failure(.e0))
                subject.send(completion: .failure(.e1))
                subject.send(completion: .failure(.e2))
                
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
            
            // MARK: 1.4 should not send values before the subscriber requests
            it("should not send values before the subscriber requests") {
                let subject = PassthroughSubject<Int, CustomError>()
                
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subject.subscribe(sub)
                subject.send(1)
                subject.send(1)
                
                expect(sub.events).to(beEmpty())
            }
            
            // MARK: 1.5 should send completion even if the subscriber does not request
            it("should send completion even if the subscriber does not request") {
                let subject = PassthroughSubject<Int, CustomError>()
                
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subject.subscribe(sub)
                subject.send(completion: .failure(.e0))
                
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
            
            // MARK: 1.6 should not send events after the subscription is cancelled
            it("should not send events after the subscription is cancelled") {
                let subject = PassthroughSubject<Int, CustomError>()
                
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    s.cancel()
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subject.subscribe(sub)
                
                subject.send(1)
                subject.send(completion: .failure(.e0))
                
                expect(sub.events).to(beEmpty())
            }
            
            // MARK: 1.7 should resend completion if the subscription happens after sending completion
            it("should resend completion if the subscription happens after sending completion") {
                let subject = PassthroughSubject<Int, CustomError>()
                subject.send(completion: .finished)
                
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                subject.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
            // MARK: 1.8 should send as many values to multi-subscribers as their demands
            it("should send as many values to multi-subscribers as their demands") {
                let subject = PassthroughSubject<Int, Error>()
                
                var subs: [CustomSubscriber<Int, Error>] = []
                let nums = (0..<10).map { _ in Int.random(in: 0..<10) }
                
                for i in nums {
                    let sub = CustomSubscriber<Int, Error>(receiveSubscription: { s in
                        s.request(.max(i))
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { c in
                    })
                    
                    subject.subscribe(sub)
                    
                    subs.append(sub)
                }
                
                for i in 0..<10 {
                    subject.send(i)
                }
                
                for (i, sub) in zip(nums, subs) {
                    expect(sub.events.count).to(equal(i))
                }
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 should retain subscriptions then release them after sending completion
            it("should retain subscriptions then release them after sending completion") {
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
            
            // MARK: 2.2 should retain subscribers then release them after sending completion
            it("should retain subscribers then release them after sending completion") {
                let pub = PassthroughSubject<Int, Never>()
                
                weak var subObj: AnyObject?
                
                do {
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        s.request(.max(1))
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { c in
                    })
                    subObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(subObj).toNot(beNil())
                pub.send(completion: .finished)
                expect(subObj).to(beNil())
            }
            
            // MARK: 2.3 should retain subscriptions then release them after them are cancelled
            it("should retain subscriptions then release them after them are cancelled") {
                let pub = PassthroughSubject<Int, Never>()
                
                weak var subscriptionObj: AnyObject?
                
                do {
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        subscriptionObj = s as AnyObject
                        s.request(.max(1))
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { c in
                    })
                    
                    pub.subscribe(sub)
                }
                
                expect(subscriptionObj).toNot(beNil())
                
                (subscriptionObj as? Subscription)?.cancel()
                
                expect(subscriptionObj).to(beNil())
            }
            
            // MARK: 2.4 should not retain sub if the subscription happens after sending completion
            it("should not retain sub if the subscription happens after sending completion") {
                let pub = PassthroughSubject<Int, Never>()
                pub.send(completion: .finished)

                weak var subObj: AnyObject?
                
                do {
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        s.request(.max(1))
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { c in
                    })
                    subObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(subObj).to(beNil())
            }
            
            // MARK: 2.5 subscription should retain pub and sub then release pub after sending completion
            it("subscription should retain pub and sub then release pub after sending completion") {
                var subscription: Subscription?
                weak var pubObj: PassthroughSubject<Int, Never>?
                weak var subObj: AnyObject?
                
                do {
                    let pub = PassthroughSubject<Int, Never>()
                    pubObj = pub
                    
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        s.request(.max(1))
                        subscription = s
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    subObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(pubObj).toNot(beNil())
                expect(subObj).toNot(beNil())
                
                pubObj?.send(completion: .finished)
                
                expect(pubObj).to(beNil())
                expect(subObj).toNot(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.6 subscription should retain pub and sub then release pub after cancelling
            it("subscription should retain pub and sub then release pub after cancelling") {
                var subscription: Subscription?
                weak var pubObj: PassthroughSubject<Int, Never>?
                weak var subObj: AnyObject?
                
                do {
                    let pub = PassthroughSubject<Int, Never>()
                    pubObj = pub
                    
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        s.request(.max(1))
                        subscription = s
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    subObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(pubObj).toNot(beNil())
                expect(subObj).toNot(beNil())
                
                subscription?.cancel()
                
                expect(pubObj).to(beNil())
                expect(subObj).toNot(beNil())
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 3.1 should be able to send value concurrently
            it("should be able to send value concurrently") {
                let pub = PassthroughSubject<Int, Never>()
                
                var enters: [Date] = []
                var exits: [Date] = []
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    Thread.sleep(forTimeInterval: 1)
                    return .none
                }, receiveCompletion: { s in
                })
                
                pub.subscribe(sub)
                
                let g = DispatchGroup()
                let q = DispatchQueue(label: UUID().uuidString)
                
                for i in 0..<3 {
                    DispatchQueue.global().async(group: g) {
                        q.async {
                            enters.append(Date())
                        }
                        pub.send(i)
                        q.async {
                            exits.append(Date())
                        }
                    }
                }
                
                g.wait()
                
                q.sync {
                    expect(enters.max()).to(beLessThan(exits.min()))
                }
            }
            
            // MARK: 3.2 should send as many values as the subscriber's demand even if these are sent concurrently
            it("should send as many values as the subscriber's demand even if these are sent concurrently") {
                let subject = PassthroughSubject<Int, Never>()
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(10))
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
                
                expect(sub.events.count).to(equal(10))
            }
            
            // MARK: 3.3 no guarantee of synchronous backpressure
            it("no guarantee of synchronous backpressure") {
                let subject = PassthroughSubject<Int, Never>()
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    if v == 1 {
                        Thread.sleep(forTimeInterval: 1)
                        return .max(5)
                    }
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
                
                expect(sub.events.count).to(equal(10))
            }
        }
    }
}
