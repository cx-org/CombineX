import CXShim
import CXTestUtility
import Nimble
import Quick

class TryDropWhileSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should drop until predicate return false
            it("should drop until predicate return false") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.tryDrop(while: { $0 < 50 })
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                subject.send(contentsOf: 0..<100)
                subject.send(completion: .finished)
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                
                let valueEvents = (50..<100).map(TracingSubscriber<Int, TestError>.Event.value)
                let expected = valueEvents + [.completion(.finished)]
                
                expect(got) == expected
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = pub
                    .tryDrop { $0 < 50 }
                    .subscribeTracingSubscriber(initialDemand: .max(10))
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.eventsWithoutSubscription.count) == 10
            }
            
            // MARK: 1.3 should fail if predicate throws error
            it("should fail if predicate throws error") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = pub
                    .tryDrop { _ in throw TestError.e0 }
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                expect(got) == [.completion(.failure(.e0))]
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.4 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryDrop { _ in true }
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.5 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.tryDrop { _ in true }

                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
