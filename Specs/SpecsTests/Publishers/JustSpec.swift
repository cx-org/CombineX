import Quick
import Nimble

#if CombineX
import CombineX
#else
import Combine
#endif

class JustSpec: QuickSpec {
    
    override func spec() {
        let just = Publishers.Just(1)
        
        it("should send value then send completion") {
            var count = 0
            
            _ = just.sink(receiveCompletion: { (c) in
                count += 1
                expect(c.isFinished).to(beTrue())
            }, receiveValue: { v in
                count += 1
                expect(v).to(equal(1))
            })
            
            expect(count).to(equal(2))
        }
        
        it("should release subscriber when complete") {
            weak var subscriber: CustomSubscriber<Int, Never>?
            
            do {
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    s.request(.max(1))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subscriber = sub
                just.subscribe(sub)
            }
            
            expect(subscriber).to(beNil())
        }
        
        it("should work well when subscription request concurrently") {
            var count = 0
            
            let g = DispatchGroup()
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                for _ in 0..<100 {
                    g.enter()
                    DispatchQueue.global().async {
                        g.leave()
                        s.request(.max(1))
                    }
                }
            }, receiveValue: { v in
                count += 1
                return .none
            }, receiveCompletion: { c in
            })
            
            just.subscribe(sub)
            
            g.wait()
            
            expect(count).to(equal(1))
        }
    }
}
