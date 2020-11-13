import CXShim
import CXTestUtility
import Nimble
import Quick

class TryReduceSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should reduce values from upstream
            it("should reduce values from upstream") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = subject
                    .tryReduce(0) { $0 + $1 }
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<100)
                subject.send(completion: .finished)
                
                let reduced = (0..<100).reduce(0) { $0 + $1 }
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }

                expect(got) == [.value(reduced), .completion(.finished)]
            }
            
            // MARK: 1.2 should fail if closure throws an error
            it("should fail if closure throws an error") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = subject
                    .tryReduce(0) { _, _ in throw TestError.e0 }
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<100)
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                expect(got) == [.completion(.failure(.e0))]
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.3 should throw assertion when the demand is 0
            it("should throw assertion when the demand is 0") {
                let pub = Empty<Int, TestError>().tryReduce(0) { $0 + $1 }
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .max(0))
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryReduce(0) { $0 + $1 }
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.5 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.tryReduce(0) { $0 + $1 }

                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
