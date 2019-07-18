import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class DropUntilOutputSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Drop
        describe("Drop") {
            
            fit("test") {
                let pub0 = CustomPublisher<Int, Never> { (s) in
                    s.receive(subscription: CustomSubscription(request: { (d) in
                        print("pub0 subscription: request demand", d)
                    }, cancel: {
                        print("pub0 subscription: cancel")
                    }))
                    s.receive(1)
                    s.receive(2)
                    s.receive(3)
                    print("pub0 send values")
                }
                let pub1 = CustomPublisher<Int, Never> { (s) in
                    s.receive(subscription: CustomSubscription(request: { (d) in
                        print("pub1 subscription: request demand", d)
                    }, cancel: {
                        print("pub1 subscription: cancel")
                    }))
                    _ = s.receive(-1)
                    print("pub1 send values")
                    s.receive(completion: .finished)
                }
                
                let pub = pub0.drop(untilOutputFrom: pub1)
                
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(10))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                subscription?.cancel()
                
                print(sub.events)
            }
            
            it("should drop") {
                
                let pub0 = PassthroughSubject<Int, CustomError>()
                let pub1 = PassthroughSubject<Int, CustomError>()
                
                let pub = pub0.drop(untilOutputFrom: pub1)
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                pub0.send(0)
                pub0.send(1)
                pub0.send(2)
                
                pub1.send(completion: .failure(.e0))
//                pub1.send(3)
                
                pub0.send(4)
                
//                pub0.send(3)
//                pub0.send(4)
//                pub0.send(5)
//
                print(sub.events)
            }
        }
    }
}
