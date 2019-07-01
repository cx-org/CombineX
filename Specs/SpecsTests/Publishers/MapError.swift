import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class MapErrorSpec: QuickSpec {
    
    override func spec() {
        
        func makeCustomSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> CustomSubscriber<Input, Failure> {
            return CustomSubscriber<Input, Failure>(receiveSubscription: { (s) in
                s.request(demand)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
        }
        
        // MARK: * should map error
        it("should map error") {
            
            let fail = Publishers.Fail<Int, CustomError>(error: .e0)
            
            let pub = fail.mapError { _ in CustomError.e1 }
            
            let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
            
            pub.subscribe(sub)
            
            expect(sub.events).to(equal([.completion(.failure(.e1))]))
        }
    }
}
