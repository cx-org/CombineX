import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class TryReduceSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should reduce values from upstream
            it("should reduce values from upstream") {
                let values = 0..<100
                
                let seq = Publishers.Sequence<[Int], Never>(sequence: Array(values))
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                seq.tryReduce(0) {
                    $0 + $1
                }.subscribe(sub)
                
                let reduced = values.reduce(0) { $0 + $1 }
                let got = sub.events.map {
                    $0.mapError { $0 as! CustomError }
                }

                expect(got).to(equal([.value(reduced), .completion(.finished)]))
            }
            
            // MARK: 1.2 should fail if closure throws an error
            it("should fail if closure throws an error") {
                let values = 0..<100
                
                let seq = Publishers.Sequence<[Int], Never>(sequence: Array(values))
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                seq.tryReduce(0) {
                    if $0 == 10 {
                        throw CustomError.e0
                    }
                    return $0 + $1
                }.subscribe(sub)
                
                let got = sub.events.map {
                    $0.mapError { $0 as! CustomError }
                }
                expect(got).to(equal([.completion(.failure(.e0))]))
            }
            
            #if !SWIFT_PACAKGE
            // MARK: 1.3 should throw assertion when the demand is 0
            it("should throw assertion when the demand is 0") {
                let pub = Publishers.Empty<Int, CustomError>().tryReduce(0) { $0 + $1 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .max(0))
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = CustomPublisher<Int, CustomError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryReduce(0) { $0 + $1 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.5 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = CustomPublisher<Int, CustomError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.tryReduce(0) { $0 + $1 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)

                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
