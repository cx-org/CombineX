import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class MapSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should map value from upstream
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
        
        // MARK: It should release upstream, transform closure and sub when cancel
        it("should release upstream, transform closure and sub when cancel") {
            
            weak var upstreamObj: AnyObject?
            weak var closureObj: CustomObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                upstreamObj = subject
                
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
            
            expect(upstreamObj).toNot(beNil())
            expect(closureObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            subscription?.cancel()
            
            expect(upstreamObj).to(beNil())
            expect(closureObj).to(beNil())
            expect(subObj).to(beNil())
        }
        
        // MARK: It should release upstream, transform closure and sub when finished
        it("should release upstream, transform closure and sub when finished") {
            
            weak var upstreamObj: PassthroughSubject<Int, Never>?
            weak var closureObj: CustomObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                upstreamObj = subject
                
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
            
            expect(upstreamObj).toNot(beNil())
            expect(closureObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            upstreamObj?.send(completion: .finished)
            
            expect(upstreamObj).to(beNil())
            expect(closureObj).to(beNil())
            expect(subObj).to(beNil())
            
            _ = subscription
        }
        
        // MARK: It should work well when upstream send value concurrently
        it("should work well when upstream send value concurrently") {
            let subject = CustomSubject<Int, Never>()
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.max(5))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            subject.map { $0 }.subscribe(sub)
        
            let g = DispatchGroup()
            20.times { i in
                DispatchQueue.global().async(group: g) {
                    subject.send(i)
                }
            }
            
            g.wait()
            
            expect(sub.events.count).to(equal(5))
        }
    }
    
}
