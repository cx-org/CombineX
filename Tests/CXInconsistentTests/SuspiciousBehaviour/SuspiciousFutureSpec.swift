import CXShim
import CXTestUtility
import Nimble
import Quick

class SuspiciousFutureSpec: QuickSpec {
    
    override func spec() {
        
        it("should send failure even without demand") {
            let future = Future<Int, TestError> { promise in
                promise(.failure(.e0))
            }
            
            let sub = future.subscribeTracingSubscriber(initialDemand: nil)
            
            expect(sub.events.first?.isSubscription) == true
            // SUSPICIOUS: Combine won't send failure if no request is received.
            expect(sub.eventsWithoutSubscription).toBranch(
                combine: beEmpty(),
                cx: equal([.completion(.failure(.e0))]))
        }
        
        it("should not leak subscription") {
            var promise: Future<Int, TestError>.Promise?
            let future = Future<Int, TestError> { promise = $0 }
            weak var weakSubscription: AnyObject?
            
            do {
                let sub = future.subscribeTracingSubscriber(initialDemand: .max(1))
                weakSubscription = sub.subscription as AnyObject?
                
                promise?(.success(1))
                
                sub.releaseSubscription()
            }
            
            // SUSPICIOUS: Combine leaks subscription
            expect(weakSubscription).toBranch(
                combine: beNotNil(),
                cx: beNil())
        }
    }
}
