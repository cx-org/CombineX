import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class TryReduceSpec: QuickSpec {
    
    override func spec() {
        
        func makeCustomSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> CustomSubscriber<Input, Failure> {
            return CustomSubscriber<Input, Failure>(receiveSubscription: { (s) in
                s.request(demand)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
        }
        
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
                
                let final = values.reduce(0) { $0 + $1 }
                for (i, event) in sub.events.enumerated() {
                    switch i {
                    case 0:
                        expect(event.isValue(final)).to(beTrue())
                    case 1:
                        expect(event.isFinished()).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            
            // MARK: 1.2 should fail if closure throws error
            it("should fail if closure throws error") {
                let values = 0..<100
                
                let seq = Publishers.Sequence<[Int], Never>(sequence: Array(values))
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                seq.tryReduce(0) {
                    if $0 == 10 {
                        throw CustomError.e0
                    } else {
                        return $0 + $1
                    }
                }.subscribe(sub)
                
                expect(sub.events.count).to(equal(1))
                expect(sub.events.first?.error).to(matchError(CustomError.e0))
            }
            
            #if !SWIFT_PACAKGE
            // MARK: 1.3 should crash when the demand is 0
            it("should crash when the demand is 0") {
                let pub = Just(1).tryReduce(0) { $0 + $1 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .max(0))
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
