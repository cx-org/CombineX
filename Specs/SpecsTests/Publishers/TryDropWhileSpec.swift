import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class TryDropWhileSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should drop until predicate return false
            it("should drop until predicate return false") {
                let sequence = Publishers.Sequence<[Int], Never>(sequence: Array(0..<100))
                
                let pub = sequence.tryDrop(while: { $0 < 50 })
                
                let subscriber = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(subscriber)
                
                expect(subscriber.events.count).to(equal(51))
                for (event, value) in zip(subscriber.events.dropLast(), (50..<100)) {
                    switch event {
                    case .value(let i):
                        expect(i).to(equal(value))
                    default:
                        fail()
                    }
                }
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .max(10))
                
                pub.tryDrop { $0 < 50 }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.events.count).to(equal(10))
            }
            
            // MARK: 1.3 should fail if predicate throws error
            it("should fail if predicate throws error") {
                let pub = PassthroughSubject<Int, CustomError>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryDrop { _ in
                    throw CustomError.e0
                }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                expect(sub.events.count).to(equal(1))
                expect(sub.events.first?.error).to(matchError(CustomError.e0))
            }
        }
    }
}
