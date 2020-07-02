import CXShim
import CXTestUtility
import Nimble
import Quick

class CollectByCountSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should relay values by collection
            it("should relay values by collection") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = pub.collect(2).subscribeTracingSubscriber(initialDemand: .unlimited)
                
                pub.send(contentsOf: 0..<5)
                pub.send(completion: .failure(.e0))
                
                expect(sub.eventsWithoutSubscription) == [
                    .value([0, 1]),
                    .value([2, 3]),
                    .completion(.failure(.e0))
                ]
            }
            
            // MARK: 1.2 should send unsent values if upstream finishes
            it("should send unsent values if upstream finishes") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = pub.collect(2).subscribeTracingSubscriber(initialDemand: .unlimited)
                
                pub.send(contentsOf: 0..<5)
                pub.send(completion: .finished)
                
                expect(sub.eventsWithoutSubscription) == [
                    .value([0, 1]),
                    .value([2, 3]),
                    .value([4]),
                    .completion(.finished)
                ]
            }
            
            // MARK: 1.3 should relay as many values as demand
            it("should relay as many values as demand") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = pub.collect(2).subscribeTracingSubscriber(initialDemand: .max(1)) { v in
                    v == [0, 1] ? .max(1) : .none
                }
                
                pub.send(contentsOf: 0..<5)
                pub.send(completion: .finished)
                
                expect(sub.eventsWithoutSubscription) == [.value([0, 1]), .value([2, 3]), .completion(.finished)]
            }
        }
    }
}
