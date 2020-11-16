import CXShim
import CXTestUtility
import Nimble
import Quick

typealias OptionalPublisher<Wrapped> = Optional<Wrapped>.CX.Publisher

class OptionalSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send a value then send finished
            it("should send value then send finished") {
                let pub = OptionalPublisher<Int>(1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .completion(.finished)]
            }
            
            // MARK: 1.2 should send finished even no demand
            it("should send finished") {
                let pub = OptionalPublisher<Int>(nil)
             
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(0))
                
                expect(sub.eventsWithoutSubscription) == [.completion(.finished)]
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.3 should throw assertion when none demand is requested
            it("should throw assertion when less than one demand is requested") {
                let pub = OptionalPublisher<Int>(1)
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when none demand is requested if is nil
            it("should not throw assertion when none demand is requested if is nil") {
                let pub = OptionalPublisher<Int>(nil)
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.toNot(throwAssertion())
            }
            #endif
            
            it("Optional provide publisher property since macOS 11") {
                let pub = Optional(11).cx.publisher
                assert(pub == OptionalPublisher(11))
            }
        }
    }
}
