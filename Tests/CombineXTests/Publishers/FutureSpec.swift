import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class FutureSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Future
        describe("Future") {
            
            // MARK: 1.1 should send value and finish when promise succeed
            it("should send value and finish when promise succeed") {
                let f = Future<Int, TestError> { p in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        p(.success(1))
                    }
                }
                
                let sub = f.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == []
                expect(sub.eventsWithoutSubscription).toEventually(equal([.value(1), .completion(.finished)]))
            }
            
            // MARK: 1.2 should send failure when promise fail
            it("should send failure when promise fail") {
                let f = Future<Int, TestError> { p in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        p(.failure(.e0))
                    }
                }
                
                let sub = f.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == []
                expect(sub.eventsWithoutSubscription).toEventually(equal([.completion(.failure(.e0))]))
            }
            
            // MAKR: 1.3 should send events immediately if promise is completed
            it("should send events immediately if promise is completed") {
                let f = Future<Int, TestError> { p in
                    p(.success(1))
                }
                
                let sub = f.subscribeTracingSubscriber(initialDemand: .unlimited)
                expect(sub.eventsWithoutSubscription) == [.value(1), .completion(.finished)]
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: should send events to all subscribers even if they subscribe concurrently
            it("should send events to all subscribers even if they subscribe concurrently") {
                let g = DispatchGroup()
                
                let f = Future<Int, TestError> { p in
                    DispatchQueue.global().async(group: g) {
                        p(.failure(.e0))
                    }
                }
                let subs = (0..<100).map { _ in TracingSubscriber<Int, TestError>(receiveSubscription: { $0.request(.max(1)) }) }
                
                100.times { i in
                    DispatchQueue.global().async(group: g) {
                        f.subscribe(subs[i])
                    }
                }
                
                g.wait()
                
                for sub in subs {
                    expect(sub.eventsWithoutSubscription) == [.completion(.failure(.e0))]
                }
            }
        }
    }
}
