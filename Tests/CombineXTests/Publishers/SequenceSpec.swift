import CXShim
import CXTestUtility
import CXUtility
import Foundation
import Nimble
import Quick

class SequenceSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send values then send finished
            it("should send values then send finished") {
                let seq = 0..<100
                let pub = seq.cx.publisher
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                let valueEvents = seq.map(TracingSubscriber<Int, Never>.Event.value)
                let expected = valueEvents + [.completion(.finished)]
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = (0..<100).cx.publisher
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(50)) { v in
                    [0, 10].contains(v) ? .max(10) : .none
                }
                
                let events = (0..<70).map(TracingSubscriber<Int, Never>.Event.value)
                expect(sub.eventsWithoutSubscription) == events
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should release the subscriber after complete
            it("subscription should release the subscriber after complete") {
                var subscription: Subscription?
                weak var subObj: AnyObject?
                
                do {
                    let pub = (0..<10).cx.publisher
                    let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                    subscription = sub.subscription
                    subObj = sub
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
                    let pub = (0..<10).cx.publisher
                    let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                    subscription = sub.subscription
                    subObj = sub
                }
                
                expect(subObj).toNot(beNil())
                subscription?.cancel()
                expect(subObj).to(beNil())
                
                _ = subscription
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 3.1 should send as many values as demand even if these are concurrently requested
            it("should send as many values as demand even if these are concurrently requested") {
                let pub = (0...).cx.publisher
                let sub = pub.subscribeTracingSubscriber(initialDemand: nil)
                
                DispatchQueue.global().concurrentPerform(iterations: 100) { _ in
                    sub.subscription?.request(.max(1))
                }
                
                expect(sub.eventsWithoutSubscription.count) == 100
            }
            
            // MARK: 3.2 receiving value should not block cancel
            it("receiving value should not block") {
                let pub = (0...).cx.publisher
                let sub = pub.subscribeTracingSubscriber(initialDemand: nil) { _ in
                    Thread.sleep(forTimeInterval: 0.1)
                    return .none
                }
                
                let status = LockedAtomic(0)
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    sub.subscription?.cancel()
                    status.store(2)
                }
                
                sub.subscription?.request(.max(5))
                status.store(1)
                
                expect(status.load()) == 1
            }
        }
    }
}
