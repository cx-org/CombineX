import CXShim
import CXTestUtility
import Nimble
import Quick

class TryReduceSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should reduce values from upstream
            it("should reduce values from upstream") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                subject.tryReduce(0) {
                    $0 + $1
                }.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                subject.send(completion: .finished)
                
                let reduced = (0..<100).reduce(0) { $0 + $1 }
                let got = sub.events.mapError { $0 as! TestError }

                expect(got) == [.value(reduced), .completion(.finished)]
            }
            
            // MARK: 1.2 should fail if closure throws an error
            it("should fail if closure throws an error") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                subject.tryReduce(0) { _, _ in
                    throw TestError.e0
                }.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                let got = sub.events.mapError { $0 as! TestError }
                expect(got) == [.completion(.failure(.e0))]
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.3 should throw assertion when the demand is 0
            it("should throw assertion when the demand is 0") {
                let pub = Empty<Int, TestError>().tryReduce(0) { $0 + $1 }
                let sub = makeTestSubscriber(Int.self, Error.self, .max(0))
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryReduce(0) { $0 + $1 }
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
                
                let pub = upstream.tryReduce(0) { $0 + $1 }
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)

                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
