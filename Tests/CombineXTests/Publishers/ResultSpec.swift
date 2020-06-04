import CXShim
import CXTestUtility
import Dispatch
import Nimble
import Quick

typealias ResultPublisher<Success, Failure: Error> = Result<Success, Failure>.CX.Publisher

class ResultSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send a value then send finished
            it("should send value then send finished") {
                let pub = ResultPublisher<Int, TestError>(1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .completion(.finished)]
            }
            
            // MARK: 1.2 should send failure even no demand
            it("should send failure") {
                let pub = ResultPublisher<Int, TestError>(.e0)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(0))
                
                expect(sub.eventsWithoutSubscription) == [.completion(.failure(.e0))]
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.3 should throw assertion when none demand is requested
            it("should throw assertion when less than one demand is requested") {
                let pub = ResultPublisher<Int, TestError>(1)
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when none demand is requested if is nil
            it("should not throw assertion when none demand is requested if is failure") {
                let pub = ResultPublisher<Int, TestError>(.e0)
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
