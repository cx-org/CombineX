import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class SinkSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should receive values and completion
        it("should receive values and completion") {
            let pub = PassthroughSubject<Int, Never>()
            
            var valueCount = 0
            var completionCount = 0
            
            let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { (c) in
                completionCount += 1
            }, receiveValue: { v in
                valueCount += 1
            })
            
            pub.subscribe(sink)
            
            pub.send(1)
            pub.send(1)
            pub.send(completion: .finished)
            pub.send(1)
            pub.send(completion: .finished)
            
            expect(valueCount).to(equal(2))
            expect(completionCount).to(equal(1))
        }
        
        // MARK: It should release subscription when receive completion
        it("should release subscription when receive completion") {
            
            let sink = Subscribers.Sink<Int, Never>(
                receiveCompletion: { c in
            },
                receiveValue: { v in
            }
            )
            
            weak var subscription: CustomSubscription?
            
            do {
                let s = CustomSubscription(
                    request: { (demand) in
                },
                    cancel: {
                }
                )
                
                sink.receive(subscription: s)
                subscription = s
            }
            
            expect(subscription).toNot(beNil())
            sink.receive(completion: .finished)
            expect(subscription).to(beNil())
        }
    }
}
