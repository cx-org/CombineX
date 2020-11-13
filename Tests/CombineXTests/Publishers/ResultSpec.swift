import CXShim
import CXTestUtility
import Dispatch
import Nimble
import Quick

typealias ResultPublisher<Success, Failure: Error> = Result<Success, Failure>.CX.Publisher

class ResultSpec: QuickSpec {
    
    override func spec() {
        
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
            
            #if arch(x86_64) && canImport(Darwin)
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
        
        // MARK: - Specializations
        describe("Specializations") {
            
            // MARK: 2.1
            it("should capture error on specialized tryMin/tryMax") {
                let pub = ResultPublisher<Int, TestError>(1)
                let err = TestError.e0
                
                let r1 = pub.tryMin(by: { _, _ in throw err }).result
                expect { try r1.get() }.to(throwError(err))
                let r2 = pub.tryMax(by: { _, _ in throw err }).result
                expect { try r2.get() }.to(throwError(err))
            }
        }
    }
}
