import CXShim
import CXTestUtility
import Nimble
import Quick

class MapErrorSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: Relay
        describe("Relay") {
            
            // MARK: 1.1 should map error
            it("should map error") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = pub
                    .mapError { _ in TestError.e2 }
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .failure(.e0))
                
                let valueEvents = (0..<100).map { TracingSubscriberEvent<Int, TestError>.value($0) }
                let expected = valueEvents + [.completion(.failure(.e2))]
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.2 should throw assertion when upstream send values before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                let pub = upstream.mapError { $0 as Error }
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.3 should throw assertion when upstream send completion before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                let pub = upstream.mapError { $0 as Error }
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
