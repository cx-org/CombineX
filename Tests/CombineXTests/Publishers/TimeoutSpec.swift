import CXShim
import CXTestUtility
import Nimble
import Quick

class TimeoutSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should fail after the specified interval
            it("should fail after the specified interval") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                
                let pub = subject.timeout(.seconds(5), scheduler: scheduler, customError: { TestError.e0 })
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                
                pub.subscribe(sub)

                scheduler.advance(by: .seconds(4))
                expect(sub.events) == []
                
                scheduler.advance(by: .seconds(5))
                expect(sub.events) == [.completion(.failure(.e0]))
            }
            
            // MARK: 1.2 should finish if `customError` is nil
            it("should finish if `customError` is nil") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                
                let pub = subject.timeout(.seconds(5), scheduler: scheduler)
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                
                pub.subscribe(sub)
                
                scheduler.advance(by: .seconds(6))
                expect(sub.events) == [.completion(.finished)]
            }
            
            // MARK: 1.3 should send timeout event in scheduled action
            it("should send timeout error in scheduled action") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestDispatchQueueScheduler.serial()
                
                let pub = subject.timeout(.seconds(0.01), scheduler: scheduler, customError: { TestError.e0 })
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { _ in
                    return .none
                }, receiveCompletion: { _ in
                    expect(scheduler.isCurrent) == true
                })
                
                pub.subscribe(sub)
                expect(sub.events).toEventually(equal([.completion(.failure(TestError.e0))]))
            }
        }
    }
}
