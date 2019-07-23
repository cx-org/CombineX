import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class MapErrorSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Relay
        describe("Relay") {
            
            // MARK: 1.1 should map error
            it("should map error") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.mapError { _ in .e2 }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .failure(.e0))
                
                let valueEvents = (0..<100).map { TestEvent<Int, TestError>.value($0) }
                let expected = valueEvents + [.completion(.failure(.e2))]
                expect(sub.events).to(equal(expected))
            }
         
            
            #if !SWIFT_PACKAGE
            // MARK: 1.2 should throw assertion when upstream send values before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.mapError { $0 as Error }
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.3 should throw assertion when upstream send completion before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.mapError { $0 as Error }
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
