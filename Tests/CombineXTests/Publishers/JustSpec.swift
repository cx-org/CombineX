import CXShim
import CXTestUtility
import Dispatch
import Foundation
import Nimble
import Quick

class JustSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send a value then send finished
            it("should send value then send finished") {
                let pub = Just<Int>(1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .completion(.finished)]
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.2 should throw assertion when none demand is requested
            it("should throw assertion when less than one demand is requested") {
                let pub = Just<Int>(1)
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            
            // TODO: not at macOS 10.15.7, should move to verisoning test
            // MARK: 1.3 should throw assertion when none demand is requested even after completion
            xit("should throw assertion when less than one demand is requested even after completion") {
                let pub = Just<Int>(1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect {
                    sub.subscription?.request(.max(0))
                }.to(throwAssertion())
            }
            #endif
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should release the subscriber after complete
            it("subscription should release the subscriber after complete") {
                var subscription: Subscription?
                weak var subObj: AnyObject?
                
                do {
                    let pub = Just<Int>(1)
                    let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                    subObj = sub
                    subscription = sub.subscription
                }
                
                expect(subObj).toNot(beNil())
                subscription?.request(.unlimited)
                expect(subObj).to(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.2 subscription should release the subscriber after cancel
            it("subscription should release the subscriber after cancel") {
                var subscription: Subscription?
                weak var subObj: AnyObject?
                
                do {
                    let pub = Just<Int>(1)
                    let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                    subObj = sub
                    subscription = sub.subscription
                }
                
                expect(subObj).toNot(beNil())
                subscription?.cancel()
                expect(subObj).to(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.3 subscription should not release the initial object after complete
            it("subscription should not release the initial object after complete") {
                var subscription: Subscription?
                weak var testObj: AnyObject?
                
                do {
                    let obj = NSObject()
                    testObj = obj
                    
                    let pub = Just(obj)
                    let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                    subscription = sub.subscription
                }
                
                expect(testObj).toNot(beNil())
                subscription?.request(.unlimited)
                expect(testObj).toNot(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.4 subscription should not release the initial object after cancel
            it("subscription should not release the initial object after cancel") {
                var subscription: Subscription?
                weak var testObj: AnyObject?
                
                do {
                    let obj = NSObject()
                    testObj = obj
                    
                    let pub = Just<NSObject>(obj)
                    let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                    subscription = sub.subscription
                }

                expect(testObj).toNot(beNil())
                subscription?.cancel()
                expect(testObj).toNot(beNil())
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 3.1 should only send only one value even if the subscription requests it multiple times concurrently
            it("should only send only one value even if the subscription requests it multiple times concurrently") {
                let pub = Just<Int>(1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                
                let g = DispatchGroup()
                for _ in 0..<100 {
                    DispatchQueue.global().async(group: g) {
                        sub.subscription?.request(.max(1))
                    }
                }
                g.wait()
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .completion(.finished)]
            }
        }
    }
}
