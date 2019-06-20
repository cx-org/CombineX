import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class MapSpec: QuickSpec {
    
    override func spec() {
        
        it("should map value from upstream") {
            
            let pub = PassthroughSubject<Int, CustomError>()
            
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.map { $0 * 2 }.subscribe(sub)
            
            let nums = [1, 2, 3]
            for num in nums {
                pub.send(num)
            }
            
            for (num, event) in zip(nums, sub._events) {
                expect(event).to(equal(.value(num * 2)))
            }
        }
        
        it("should free pub and sub when cancel") {
            
            weak var pubObj: AnyObject?
            weak var closureObj: CustomObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let pObj = CustomObject()
                closureObj = pObj
                
                let subject = PassthroughSubject<Int, Never>()
                pubObj = subject
                
                let pub = subject.map { (v) -> Int in
                    
                    pObj.fn()
                    return v
                }
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                    
                })
                
                subObj = sub
                pub.subscribe(sub)
            }
            
            expect(pubObj).toNot(beNil())
            expect(closureObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            subscription?.cancel()
            
            expect(pubObj).to(beNil())
            expect(closureObj).to(beNil())
            expect(subObj).to(beNil())
        }
        
        it("should release pub and sub when finished") {
            
            let subject = PassthroughSubject<Int, Never>()
            
            var subscription: Subscription?
            
            weak var closureObj: CustomObject?
            weak var subObj: AnyObject?
            
            do {
                let pObj = CustomObject()
                closureObj = pObj
                
                let pub = subject.map { (v) -> Int in
                    
                    pObj.fn()
                    return v
                }
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                    
                })
                
                subObj = sub
                pub.subscribe(sub)
            }
            
            expect(closureObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            subject.send(completion: .finished)
            
            expect(closureObj).to(beNil())
            expect(subObj).to(beNil())
            
            _ = subscription
        }
    }
    
}
