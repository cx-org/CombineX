import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class TimeoutSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should fail after the specified interval
            it("should fail after the specified interval") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                
                let pub = subject.timeout(.seconds(5), scheduler: scheduler, customError: { TestError.e0 })
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)

                scheduler.advance(by: .seconds(4))
                expect(sub.eventsWithoutSubscription) == []
                
                scheduler.advance(by: .seconds(5))
                expect(sub.eventsWithoutSubscription) == [.completion(.failure(.e0))]
            }
            
            // MARK: 1.2 should finish if `customError` is nil
            it("should finish if `customError` is nil") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = VirtualTimeScheduler()
                
                let pub = subject.timeout(.seconds(5), scheduler: scheduler)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                scheduler.advance(by: .seconds(6))
                expect(sub.eventsWithoutSubscription) == [.completion(.finished)]
            }
            
            // MARK: 1.3 should send timeout event in scheduled action
            it("should send timeout error in scheduled action") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = DispatchQueue(label: UUID().uuidString).cx
                
                let pub = subject.timeout(.seconds(0.01), scheduler: scheduler, customError: { TestError.e0 })
                let sub = TracingSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveCompletion: { _ in
                    expect(scheduler.base.isCurrent) == true
                })
                pub.subscribe(sub)
                
                expect(sub.eventsWithoutSubscription).toEventually(equal([.completion(.failure(TestError.e0))]))
            }
        }
    }
}
