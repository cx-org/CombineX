import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class CurrentValueSubjectSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Events
        describe("Send Events") {
            
            // MARK: 1.1 should not send values to subscribers after sending completion
            it("should not send values to subscribers after sending completion") {
                let subject = CurrentValueSubject<Int, TestError>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(completion: .finished)
                subject.send(contentsOf: 0..<10)
                
                expect(sub.eventsWithoutSubscription) == [.value(-1), .completion(.finished)]
                expect(subject.value) == -1
            }
            
            // MARK: 1.2 should not send completion to subscribers after sending completion
            it("should not send completion to subscribers after sending completion") {
                let subject = CurrentValueSubject<Int, TestError>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(completion: .failure(.e0))
                subject.send(completion: .failure(.e1))
                subject.send(completion: .failure(.e2))
                
                expect(sub.eventsWithoutSubscription) == [.value(-1), .completion(.failure(.e0))]
            }
            
            // MARK: 1.3 should not send events after the subscription is cancelled
            it("should not send events after the subscription is cancelled") {
                let subject = CurrentValueSubject<Int, TestError>(-1)
                
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.cancel()
                })
                
                subject.subscribe(sub)
                
                subject.send(1)
                subject.send(completion: .failure(.e0))
                
                expect(sub.eventsWithoutSubscription).to(beEmpty())
            }
            
            // MARK: 
            // MARK: 1.4 should not send values before the subscriber requests
            it("should not send values before the subscriber requests") {
                let subject = CurrentValueSubject<Int, TestError>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: nil)
                
                subject.send(contentsOf: 0..<10)
                
                expect(sub.eventsWithoutSubscription).to(beEmpty())
            }
            
            // MARK: 1.5 should send completion even if the subscriber does not request
            it("should send completion even if the subscriber does not request") {
                let subject = CurrentValueSubject<Int, TestError>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: nil)
                
                subject.send(completion: .failure(.e0))
                
                expect(sub.eventsWithoutSubscription) == [.completion(.failure(.e0))]
            }
            
            // MARK: 
            // MARK: 1.6 should resend completion if the subscription happens after sending completion
            it("should resend completion if the subscription happens after sending completion") {
                let subject = CurrentValueSubject<Int, TestError>(-1)
                subject.send(completion: .finished)
                
                let sub = subject.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.completion(.finished)]
            }
        }
        
        // MARK: - Demand
        describe("Demand") {
            
            // MARK: 2.1 should send as many values as the subscriber's demand
            it("should send as many values as the subscriber's demand") {
                let subject = CurrentValueSubject<Int, TestError>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: .max(1)) { v in
                    return v == -1 ? .max(1) : .none
                }

                subject.send(contentsOf: 0..<10)
                
                expect(sub.eventsWithoutSubscription.count) == 2
                sub.subscription?.request(.max(5))

                subject.send(contentsOf: 0..<10)
                expect(sub.eventsWithoutSubscription.count) == 7
            }
            
            // MARK: 2.2 should send as many values to subscribers as their demands
            it("should send as many values to subscribers as their demands") {
                let subject = CurrentValueSubject<Int, Error>(-1)
                
                var subs: [TracingSubscriber<Int, Error>] = []
                let nums = (0..<10).map { _ in Int.random(in: 1..<10) }
                
                for i in nums {
                    let sub = subject.subscribeTracingSubscriber(initialDemand: .max(i))
                    subs.append(sub)
                }
                
                subject.send(contentsOf: 0..<10)
                
                for (i, sub) in zip(nums, subs) {
                    expect(sub.eventsWithoutSubscription.count) == i
                }
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 2.3 should fatal error when less than one demand is requested
            it("should fatal error when less than one demand is requested") {
                let subject = CurrentValueSubject<Int, Never>(-1)
                
                expect {
                    subject.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            #endif
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 3.1 should retain subscriptions then release them after sending completion
            it("should retain subscriptions then release them after sending completion") {
                let pub = CurrentValueSubject<Int, Never>(-1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(1))

                weak var subscription = sub.subscription as AnyObject
                
                sub.releaseSubscription()

                expect(subscription).toNot(beNil())
                pub.send(completion: .finished)
                expect(subscription).to(beNil())
            }
            
            // MARK: 3.2 should retain subscribers then release them after sending completion
            it("should retain subscribers then release them after sending completion") {
                let pub = CurrentValueSubject<Int, Never>(-1)
                
                weak var subObj: AnyObject?
                
                do {
                    let sub = pub.subscribeTracingSubscriber(initialDemand: .max(1))
                    subObj = sub
                }
                
                expect(subObj).toNot(beNil())
                pub.send(completion: .finished)
                expect(subObj).to(beNil())
            }
            
            // MARK: 3.3 should retain subscriptions then release them after them are cancelled
            it("should retain subscriptions then release them after them are cancelled") {
                let pub = CurrentValueSubject<Int, Never>(-1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(1))

                weak var subscription = sub.subscription as AnyObject
                
                sub.releaseSubscription()

                expect(subscription).toNot(beNil())
                (subscription as? Subscription)?.cancel()
                expect(subscription).to(beNil())
            }
            
            // MARK: 3.4 should not retain sub if the subscription happens after sending completion
            it("should not retain sub if the subscription happens after sending completion") {
                let pub = CurrentValueSubject<Int, Never>(-1)
                pub.send(completion: .finished)
                
                weak var subObj: AnyObject?
                
                do {
                    let sub = pub.subscribeTracingSubscriber(initialDemand: .max(1))
                    subObj = sub
                }
                
                expect(subObj).to(beNil())
            }
            
            // MARK: 3.5 subscription should retain pub and sub then release them after sending completion
            it("subscription should retain pub and sub then release them after sending completion") {
                var subscription: Subscription?
                weak var pubObj: CurrentValueSubject<Int, Never>?
                weak var subObj: AnyObject?
                
                do {
                    let pub = CurrentValueSubject<Int, Never>(-1)
                    pubObj = pub
                    
                    let sub = pub.subscribeTracingSubscriber(initialDemand: .max(1))
                    subObj = sub
                    
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
                weak var pubObj: CurrentValueSubject<Int, Never>?
                weak var subObj: AnyObject?
                
                do {
                    let pub = CurrentValueSubject<Int, Never>(-1)
                    pubObj = pub
                    
                    let sub = pub.subscribeTracingSubscriber(initialDemand: .max(1))
                    subObj = sub
                    
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
                let subject = CurrentValueSubject<Int, Never>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: .unlimited) { _ in
                    Thread.sleep(forTimeInterval: 0.1)
                    return .none
                }
                
                let g = DispatchGroup()
                let q = DispatchQueue(label: UUID().uuidString)
                
                var datesA: [Date] = []
                var datesB: [Date] = []
                
                for i in 0..<3 {
                    DispatchQueue.global().async(group: g) {
                        q.async {
                            datesA.append(Date())
                        }
                        subject.send(i)
                        q.async {
                            datesB.append(Date())
                        }
                    }
                }
                
                g.wait()
                
                q.sync {
                    expect(datesA.max()) < datesB.min()!
                }
                _ = sub
            }
            
            // MARK: 4.2 should send as many values as the subscriber's demand even if these are sent concurrently
            it("should send as many values as the subscriber's demand even if these are sent concurrently") {
                let subject = CurrentValueSubject<Int, Never>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: .max(10))
                
                DispatchQueue.global().concurrentPerform(iterations: 100, execute: subject.send)
                
                expect(sub.eventsWithoutSubscription.count) == 10
            }
            
            // MARK: 4.3 no guarantee of synchronous backpressure
            it("no guarantee of synchronous backpressure") {
                let subject = CurrentValueSubject<Int, Never>(-1)
                let sub = subject.subscribeTracingSubscriber(initialDemand: .max(10)) { v in
                    if v == 1 {
                        Thread.sleep(forTimeInterval: 0.1)
                        return .max(5)
                    }
                    return .none
                }
                
                DispatchQueue.global().concurrentPerform(iterations: 100, execute: subject.send)
                
                expect(sub.eventsWithoutSubscription.count) == 10
            }
        }
        
        // MARK: - Current
        describe("Current") {
            
            // MARK: 5.1 should not change current value after complete
            it("should not change current value after complete") {
                let subject = CurrentValueSubject<Int, TestError>(0)
                expect(subject.value) == 0
                subject.value = 1
                expect(subject.value) == 1
                subject.send(2)
                expect(subject.value) == 2
                
                subject.send(completion: .finished)
                
                subject.send(3)
                expect(subject.value) == 2
                
                subject.value = 4
                expect(subject.value) == 4
            }
            
            // MARK: 5.2 should not send current value if the subscription requests again
            it("should not send current value if the subscription requests again") {
                let subject = CurrentValueSubject<Int, TestError>(0)
                let sub = subject.subscribeTracingSubscriber(initialDemand: nil)
                expect(sub.eventsWithoutSubscription) == []
                
                subject.send(1)
                
                sub.subscription?.request(.max(1))
                expect(sub.eventsWithoutSubscription) == [.value(1)]
                
                sub.subscription?.request(.max(1))
                expect(sub.eventsWithoutSubscription) == [.value(1)]
            }
        }
    }
}
