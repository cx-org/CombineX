import Dispatch
import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

#if USE_COMBINE
typealias ResultPublisher<Success, Failure: Error> = Result<Success, Failure>.Publisher
#else
typealias ResultPublisher<Success, Failure: Error> = Result<Success, Failure>._Publisher
#endif

class ResultSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send a value then send finished
            it("should send value then send finished") {
                let pub = ResultPublisher<Int, CustomError>(1)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
            
            // MARK: 1.2 should send failure even no demand
            it("should send failure") {
                let pub = ResultPublisher<Int, CustomError>(.e0)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .none)
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.3 should throw assertion when none demand is requested
            it("should throw assertion when less than one demand is requested") {
                let pub = ResultPublisher<Int, CustomError>(1)
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .none)
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when none demand is requested if is nil
            it("should not throw assertion when none demand is requested if is failure") {
                let pub = ResultPublisher<Int, CustomError>(.e0)
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .none)
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
