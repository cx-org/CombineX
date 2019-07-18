import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class TryScanSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should scan values from upstream
            it("should scan values from upstream") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                subject.tryScan(0) {
                    $0 + $1
                }.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                subject.send(completion: .finished)
                
                let got = sub.events.map {
                    $0.mapError { $0 as! CustomError }
                }
                
                var initial = 0
                let valueEvents = (0..<100).map { n -> CustomEvent<Int, CustomError> in
                    initial = initial + n
                    return CustomEvent<Int, CustomError>.value(initial)
                }
                let expected = valueEvents + [.completion(.finished)]

                expect(got).to(equal(expected))
            }
            
            // MARK: 1.2 should fail if closure throws an error
            it("should fail if closure throws an error") {
                let subject = PassthroughSubject<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                subject.tryScan(0) { (_, _) in
                    throw CustomError.e0
                }.subscribe(sub)
                
                100.times {
                    subject.send($0)
                }
                
                let got = sub.events.map {
                    $0.mapError { $0 as! CustomError }
                }
                expect(got).to(equal([.completion(.failure(.e0))]))
            }
            
            #if !SWIFT_PACAKGE
            // MARK: 1.3 should not throw assertion when upstream send values before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = CustomPublisher<Int, CustomError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryScan(0) { $0 + $1 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            
            // MARK: 1.4 should not throw assertion when upstream send completion before sending subscription
            it("should not throw assertion when upstream send values before sending subscription") {
                let upstream = CustomPublisher<Int, CustomError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.tryScan(0) { $0 + $1 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)

                expect {
                    pub.subscribe(sub)
                }.toNot(throwAssertion())
            }
            #endif
        }
    }
}
