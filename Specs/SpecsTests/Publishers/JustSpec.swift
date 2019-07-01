import Dispatch
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class JustSpec: QuickSpec {
    
    override func spec() {
        let just = Publishers.Just(1)
        
        // MARK: It should send value then send completion
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
        
        // MARK: It should release subscriber and not release just target when complete
        it("should release subscriber and not release just target when complete") {
            
            var subscription: Subscription?
            weak var customObj: AnyObject?
            weak var subscriberObj: AnyObject?
            
            do {
                let obj = CustomObject()
                customObj = obj
                
                let just = Publishers.Just(obj)
                let sub = CustomSubscriber<CustomObject, Never>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subscriberObj = sub
                just.subscribe(sub)
            }
            
            expect(customObj).toNot(beNil())
            expect(subscriberObj).to(beNil())
            
            subscription?.cancel()
            
            expect(customObj).toNot(beNil())
            expect(subscriberObj).to(beNil())
            
            subscription = nil
            
            expect(customObj).to(beNil())
            expect(subscriberObj).to(beNil())
        }
        
        // MARK: It should work well when subscription request concurrently
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
        
        #if !SWIFT_PACKAGE
        // MARK: It should fatal error when request more demand 1
        it("should fatal error when request more demand 1") {
            let just = Publishers.Just(1)
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                s.request(.max(0))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            expect {
                just.subscribe(sub)
            }.to(throwAssertion())
        }
        
        // MARK: It should fatal error when request more demand 2
        it("should fatal error when request more demand 2") {
            var subscription: Subscription?
            
            let just = Publishers.Just(1)
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                subscription = s
                s.request(.max(1))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            just.subscribe(sub)
            
            expect {
                subscription?.request(.max(-1))
            }.to(throwAssertion())
        }
        #endif
    }
}
