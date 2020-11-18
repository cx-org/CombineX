import CXShim
import CXTestUtility
import Nimble
import Quick

class VersioningFutureSpec: QuickSpec {
    
    override func spec() {
        
        it("should send failure even without demand") {
            let future = Future<Int, TestError> { promise in
                promise(.failure(.e0))
            }
            
            let sub = future.subscribeTracingSubscriber(initialDemand: nil)
            
            expect(sub.events.first?.isSubscription) == true
            expect(sub.eventsWithoutSubscription).toVersioning([
                .v11_0: beEmpty(),
                .v12_0: equal([.completion(.failure(.e0))]),
            ])
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
            expect(weakSubscription).toVersioning([
                .v11_0: beNotNil(),
                .v12_0: beNil(),
            ])
        }
    }
}
