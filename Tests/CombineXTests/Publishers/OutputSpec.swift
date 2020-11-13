import CXShim
import CXTestUtility
import Nimble
import Quick

class OutputSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            xit("should not receive values even if no subscription is received") {
                let pub = AnyPublisher<Int, Error> { s in
                    _ = s.receive(0)
                    _ = s.receive(1)
                    _ = s.receive(2)
                    _ = s.receive(3)
                    _ = s.receive(4)
                }
                
                let sub = pub
                    .output(in: 0..<2)
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                
                // FIXME: Even if the upstream doesn't send subscription, the downstream still can receive values. 🤔.
                expect(got) == [.value(0), .value(1)]
            }
            
            // MARK: 1.1 should only send values specified by the range
            it("should only send values in the specified range") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.output(in: 10..<20)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<100)
                
                let valueEvents = (10..<20).map(TracingSubscriber<Int, Never>.Event.value)
                let expected = valueEvents + [.completion(.finished)]
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.2 should send values as demand
            it("should send values as demand") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.output(in: 10..<20)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(5)) { v in
                    [10, 15].contains(v) ? .max(1) : .none
                }
                
                subject.send(contentsOf: 0..<100)
                
                let expected = (10..<17).map(TracingSubscriber<Int, Never>.Event.value)
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.3 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.output(in: 0..<10)
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.output(in: 0..<10)
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
