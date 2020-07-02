import CXShim
import CXTestUtility
import Nimble
import Quick

class TryAllSatisfySpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should send true then send finished
            it("should send true then send finished") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.tryAllSatisfy { $0 < 100 }
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<10)
                subject.send(completion: .finished)
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                expect(got) == [.value(true), .completion(.finished)]
            }
            
            // MARK: 1.2 should send false then send finished
            it("should send false then send finished") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.tryAllSatisfy { $0 < 5 }
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<10)
                subject.send(completion: .finished)
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                expect(got) == [.value(false), .completion(.finished)]
            }
            
            // MARK: 1.3 should fail if closure throws an error
            it("should send true then send finished") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.tryAllSatisfy {
                    if $0 == 5 {
                        throw TestError.e0
                    }
                    return true
                }
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<10)
                subject.send(completion: .finished)
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                expect(got) == [.completion(.failure(.e0))]
            }
        }
    }
}
