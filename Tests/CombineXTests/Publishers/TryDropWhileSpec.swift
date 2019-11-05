import CXShim
import CXTestUtility
import Quick
import Nimble

class TryDropWhileSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should drop until predicate return false
            it("should drop until predicate return false") {
                let subject = PassthroughSubject<Int, Never>()
                let pub = subject.tryDrop(while: { $0 < 50 })
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                pub.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                subject.send(completion: .finished)
                
                let got = sub.events.mapError { $0 as! TestError }
                
                let valueEvents = (50..<100).map {
                    TestSubscriberEvent<Int, TestError>.value($0)
                }
                let expected = valueEvents + [.completion(.finished)]
                
                expect(got).to(equal(expected))
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .max(10))
                pub.tryDrop { $0 < 50 }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.events.count).to(equal(10))
            }
            
            // MARK: 1.3 should fail if predicate throws error
            it("should fail if predicate throws error") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                pub.tryDrop { _ in
                    throw TestError.e0
                }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                let got = sub.events.mapError { $0 as! TestError }
                expect(got).to(equal([.completion(.failure(.e0))]))
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.4 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryDrop { _ in true}
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.5 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.tryDrop { _ in true}
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)

                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
