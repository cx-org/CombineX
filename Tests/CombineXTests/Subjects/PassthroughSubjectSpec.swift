import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class PassthroughSubjectSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        describe("Send Subscription") {
               
            // MARK: 5.1 should retain all upstream subscriptions
            it("should retain all upstream subscriptions") {
                let subject = PassthroughSubject<Int, TestError>()
                
                weak var subscriptionA: AnyObject?
                weak var subscriptionB: AnyObject?
                
                do {
                    let sA = TestSubscription(name: "A")
                    let sB = TestSubscription(name: "B")
                    subject.send(subscription: sA)
                    subject.send(subscription: sB)
                    subscriptionA = sA
                    subscriptionB = sB
                }
                
                expect(subscriptionA).toNot(beNil())
                expect(subscriptionB).toNot(beNil())
            }
            
            // MARK: 5.2 should not release all upstream subscriptions after send completion
            it("should not release all upstream subscriptions after send completion") {
                let subject = PassthroughSubject<Int, TestError>()
                
                weak var subscriptionA: AnyObject?
                weak var subscriptionB: AnyObject?
                
                do {
                    let sA = TestSubscription(name: "A")
                    let sB = TestSubscription(name: "B")
                    subject.send(subscription: sA)
                    subject.send(subscription: sB)
                    subscriptionA = sA
                    subscriptionB = sB
                }
                
                expect(subscriptionA).toNot(beNil())
                expect(subscriptionB).toNot(beNil())
                
                subject.send(completion: .finished)
                
                expect(subscriptionA).toNot(beNil())
                expect(subscriptionB).toNot(beNil())
            }
            
            // MARK: 5.3 should request unlimited to upstream when a subscriber request
            it("should request unlimited to upstream when a subscriber request") {
                let subject = PassthroughSubject<Int, TestError>()
                
                let sA = TestSubscription(name: "A")
                subject.send(subscription: sA)
                expect(sA.events) == []
                
                let sub = makeTestSubscriber(Int.self, TestError.self)
                subject.subscribe(sub)
                expect(sA.events) == []
                
                sub.subscription?.request(.max(1))
                expect(sA.events) == [.request(demand: .unlimited)]
                
                sub.subscription?.cancel()
                
                let sB = TestSubscription(name: "B")
                
                subject.send(subscription: sB)
                expect(sB.events) == [.request(demand: .unlimited)]
                
                let newSub = makeTestSubscriber(Int.self, TestError.self, .max(1))
                subject.subscribe(newSub)
                
                expect(sA.events) == [.request(demand: .unlimited)]
                expect(sB.events) == [.request(demand: .unlimited)]
            }
        }
        
        // MARK: - Send Events
        describe("Send Events") {
            
            // MARK: 1.1 should not send values to subscribers after sending completion
            it("should not send values to subscribers after sending completion") {
                let subject = PassthroughSubject<Int, TestError>()
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                subject.subscribe(sub)
                
                subject.send(completion: .finished)
                
                10.times {
                    subject.send($0)
                }
                expect(sub.events) == [.completion(.finished)]
            }
            
            // MARK: 1.2 should not send completion to subscribers after sending completion
            it("should not send completion to subscribers after sending completion") {
                let subject = PassthroughSubject<Int, TestError>()
                
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                subject.subscribe(sub)
                
                subject.send(completion: .failure(.e0))
                subject.send(completion: .failure(.e1))
                subject.send(completion: .failure(.e2))
                
                expect(sub.events) == [.completion(.failure(.e0]))
            }
            
            // MARK: 1.3 should not send events after the subscription is cancelled
            it("should not send events after the subscription is cancelled") {
                let subject = PassthroughSubject<Int, TestError>()
                
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.cancel()
                }, receiveValue: { _ in
                    return .none
                }, receiveCompletion: { _ in
                })
                
                subject.subscribe(sub)
                
                subject.send(1)
                subject.send(completion: .failure(.e0))
                
                expect(sub.events).to(beEmpty())
            }

            // MARK: 1.4 should not send values before the subscriber requests
            it("should not send values before the subscriber requests") {
                let subject = PassthroughSubject<Int, TestError>()
                
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { s in
                }, receiveValue: { _ in
                    return .none
                }, receiveCompletion: { _ in
                })
                
                subject.subscribe(sub)
                subject.send(1)
                subject.send(1)
                
                expect(sub.events).to(beEmpty())
            }
            
            // MARK: 1.5 should send completion even if the subscriber does not request
            it("should send completion even if the subscriber does not request") {
                let subject = PassthroughSubject<Int, TestError>()
                
                let sub = makeTestSubscriber(Int.self, TestError.self)
                
                subject.subscribe(sub)
                subject.send(completion: .failure(.e0))
                
                expect(sub.events) == [.completion(.failure(.e0]))
            }
            
            // MARK: 1.6 should resend completion if the subscription happens after sending completion
            it("should resend completion if the subscription happens after sending completion") {
                let subject = PassthroughSubject<Int, TestError>()
                subject.send(completion: .finished)
                
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                subject.subscribe(sub)
                
                expect(sub.events) == [.completion(.finished)]
            }
        }
        
        // MARK: - Demand
        describe("Demand") {
            
            // MARK: 2.1 should send as many values as the subscriber's demand
            it("should send as many values as the subscriber's demand") {
                let subject = PassthroughSubject<Int, TestError>()
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.max(1))
                }, receiveValue: { v in
                    return v == 0 ? .max(1) : .none
                }, receiveCompletion: { _ in
                })
                
                subject.subscribe(sub)
                
                10.times {
                    subject.send($0)
                }
                
                expect(sub.events.count) == 2
                sub.subscription?.request(.max(5))
                
                10.times {
                    subject.send($0)
                }
                expect(sub.events.count) == 8
            }
            
            // MARK: 2.2 should send as many values to subscribers as their demands
            it("should send as many values to subscribers as their demands") {
                let subject = PassthroughSubject<Int, Error>()
                
                var subs: [TestSubscriber<Int, Error>] = []
                let nums = (0..<10).map { _ in Int.random(in: 1..<10) }
                
                for i in nums {
                    let sub = makeTestSubscriber(Int.self, Error.self, .max(i))
                    subs.append(sub)
                    subject.subscribe(sub)
                }
                
                10.times {
                    subject.send($0)
                }

                for (i, sub) in zip(nums, subs) {
                    expect(sub.events.count) == i
                }
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 2.3 should fatal error when less than one demand is requested
            it("should fatal error when less than one demand is requested") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Never.self, .max(0))
                
                expect {
                    subject.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 3.1 should retain subscriptions then release them after sending completion
            it("should retain subscriptions then release them after sending completion") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Never.self, .max(1))
                pub.subscribe(sub)

                weak var subscription = sub.subscription as AnyObject
                
                sub.release()

                expect(subscription).toNot(beNil())
                pub.send(completion: .finished)
                expect(subscription).to(beNil())
            }
            
            // MARK: 3.2 should retain subscribers then release them after sending completion
            it("should retain subscribers then release them after sending completion") {
                let pub = PassthroughSubject<Int, Never>()
                
                weak var subObj: AnyObject?
                
                do {
                    let sub = makeTestSubscriber(Int.self, Never.self, .max(1))
                    pub.subscribe(sub)
                    subObj = sub
                }
                
                expect(subObj).toNot(beNil())
                pub.send(completion: .finished)
                expect(subObj).to(beNil())
            }
            
            // MARK: 3.3 should retain subscriptions then release them after them are cancelled
            it("should retain subscriptions then release them after them are cancelled") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Never.self, .max(1))
                pub.subscribe(sub)

                weak var subscription = sub.subscription as AnyObject
                
                sub.release()

                expect(subscription).toNot(beNil())
                (subscription as? Subscription)?.cancel()
                expect(subscription).to(beNil())
            }
            
            // MARK: 3.4 should not retain sub if the subscription happens after sending completion
            it("should not retain sub if the subscription happens after sending completion") {
                let pub = PassthroughSubject<Int, Never>()
                pub.send(completion: .finished)
                
                weak var subObj: AnyObject?
                
                do {
                    let sub = makeTestSubscriber(Int.self, Never.self, .max(1))
                    pub.subscribe(sub)
                    subObj = sub
                }
                
                expect(subObj).to(beNil())
            }
            
            // MARK: 3.5 subscription should retain pub and sub then release them after sending completion
            it("subscription should retain pub and sub then release them after sending completion") {
                var subscription: Subscription?
                weak var pubObj: PassthroughSubject<Int, Never>?
                weak var subObj: AnyObject?
                
                do {
                    let pub = PassthroughSubject<Int, Never>()
                    pubObj = pub
                    
                    let sub = makeTestSubscriber(Int.self, Never.self, .max(1))
                    subObj = sub
                    
                    pub.subscribe(sub)
                    
                    subscription = sub.subscription
                }
                
                expect(pubObj).toNot(beNil())
                expect(subObj).toNot(beNil())
                
                pubObj?.send(completion: .finished)
                
                expect(pubObj).to(beNil())
                expect(subObj).to(beNil())
                
                _ = subscription
            }
            
            // MARK: 3.6 subscription should retain pub and sub then release them after cancelling
            it("subscription should retain pub and sub then release them after cancelling") {
                var subscription: Subscription?
                weak var pubObj: PassthroughSubject<Int, Never>?
                weak var subObj: AnyObject?
                
                do {
                    let pub = PassthroughSubject<Int, Never>()
                    pubObj = pub
                    
                    let sub = makeTestSubscriber(Int.self, Never.self, .max(1))
                    subObj = sub
                    
                    pub.subscribe(sub)
                    
                    subscription = sub.subscription
                }
                
                expect(pubObj).toNot(beNil())
                expect(subObj).toNot(beNil())
                
                subscription?.cancel()
                
                expect(pubObj).to(beNil())
                expect(subObj).to(beNil())
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 4.1 should send value concurrently
            it("should send value concurrently") {
                let pub = PassthroughSubject<Int, Never>()
                
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { _ in
                    Thread.sleep(forTimeInterval: 0.1)
                    return .none
                }, receiveCompletion: { _ in
                })
                
                pub.subscribe(sub)
                
                let g = DispatchGroup()
                let q = DispatchQueue(label: UUID().uuidString)
                
                var dateA: [Date] = []
                var dateB: [Date] = []
                
                for i in 0..<3 {
                    DispatchQueue.global().async(group: g) {
                        q.async {
                            dateA.append(Date())
                        }
                        pub.send(i)
                        q.async {
                            dateB.append(Date())
                        }
                    }
                }
                
                g.wait()
                
                q.sync {
                    expect(dateA.max()) < dateB.min()
                }
            }
            
            // MARK: 4.2 should send as many values as the subscriber's demand even if these are sent concurrently
            it("should send as many values as the subscriber's demand even if these are sent concurrently") {
                let subject = PassthroughSubject<Int, Never>()
                
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { _ in
                    return .none
                }, receiveCompletion: { _ in
                })
                
                subject.subscribe(sub)
                
                let g = DispatchGroup()
                
                100.times { i in
                    DispatchQueue.global().async(group: g) {
                        subject.send(i)
                    }
                }
                
                g.wait()
                
                expect(sub.events.count) == 10
            }
            
            // MARK: 4.3 no guarantee of synchronous backpressure
            it("no guarantee of synchronous backpressure") {
                let subject = PassthroughSubject<Int, Never>()
                
                let sub = TestSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { v in
                    if v == 1 {
                        Thread.sleep(forTimeInterval: 0.1)
                        return .max(5)
                    }
                    return .none
                }, receiveCompletion: { _ in
                })
                
                subject.subscribe(sub)
                
                let g = DispatchGroup()
                
                100.times { i in
                    DispatchQueue.global().async(group: g) {
                        subject.send(i)
                    }
                }

                g.wait()
                
                expect(sub.events.count) == 10
            }
        }
    }
}
