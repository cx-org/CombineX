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
            
            for (num, event) in zip(nums, sub.events) {
                expect(event).to(equal(.value(num * 2)))
            }
        }
        
        it("should release pub and sub when cancel") {
            
            weak var originalPubObj: AnyObject?
            weak var closureObj: CustomObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                originalPubObj = subject
                
                let obj = CustomObject()
                closureObj = obj
                
                let pub = subject.map { (v) -> Int in
                    obj.fn()
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
            
            expect(originalPubObj).toNot(beNil())
            expect(closureObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            subscription?.cancel()
            
            expect(originalPubObj).to(beNil())
            expect(closureObj).to(beNil())
            expect(subObj).to(beNil())
        }
        
        it("should release pub and sub when finished") {
            
            weak var originalPubObj: PassthroughSubject<Int, Never>?
            weak var closureObj: CustomObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                originalPubObj = subject
                
                let obj = CustomObject()
                closureObj = obj
                
                let pub = subject.map { (v) -> Int in
                    obj.fn()
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
            
            expect(originalPubObj).toNot(beNil())
            expect(closureObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            originalPubObj?.send(completion: .finished)
            
            expect(originalPubObj).to(beNil())
            expect(closureObj).to(beNil())
            expect(subObj).to(beNil())
            
            _ = subscription
        }
    }
    
}
