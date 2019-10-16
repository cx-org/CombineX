import CXShim
import Quick
import Nimble

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
                expect(sub.events).to(equal([]))
                
                scheduler.advance(by: .seconds(5))
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
            
            // MARK: 1.2 should finish if `customError` is nil
            it("should finish if `customError` is nil") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestScheduler()
                
                let pub = subject.timeout(.seconds(5), scheduler: scheduler)
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                
                pub.subscribe(sub)
                
                scheduler.advance(by: .seconds(6))
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
            // MARK: 1.3 should send timeout event in scheduled action
            it("should send timeout error in scheduled action") {
                let subject = PassthroughSubject<Int, TestError>()
                let scheduler = TestDispatchQueueScheduler.serial()
                
                let pub = subject.timeout(.seconds(0.01), scheduler: scheduler, customError: { TestError.e0 })
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                    expect(scheduler.isCurrent).to(beTrue())
                })
                
                pub.subscribe(sub)
                expect(sub.events).toEventually(equal([.completion(.failure(TestError.e0))]))
            }
        }
    }
}
