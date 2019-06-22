import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class OnceSpec: QuickSpec {
    
    override func spec() {
        
        it("should send value then send completion") {
            let once = Publishers.Once<Int, CustomError>(.success(1))
            var count = 0
            _ = once.sink(
                receiveCompletion: { (completion) in
                    count += 1
                    expect(completion.isFinished).to(beTrue())
                },
                receiveValue: { value in
                    count += 1
                    expect(value).to(equal(1))
                }
            )
            
            expect(count).to(equal(2))
        }
        
        it("should send error") {
            let once = Publishers.Once<Int, CustomError>(.failure(.e0))
            var count = 0
            _ = once.sink(
                receiveCompletion: { (completion) in
                    count += 1
                    expect(completion.isFailure).to(beTrue())
                },
                receiveValue: { value in
                    count += 1
                }
            )
            
            expect(count).to(equal(1))
        }
        
        it("should release sub after complete") {
            let once = Publishers.Once<Int, CustomError>(.success(1))
            
            weak var subscriber: CustomSubscriber<Int, CustomError>?
            
            do {
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    s.request(.max(1))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { s in
                })
                
                subscriber = sub
                once.subscribe(sub)
            }
            
            expect(subscriber).to(beNil())
        }
        
        it("should work well when subscription request concurrently") {
            let once = Publishers.Once<Int, CustomError>(.success(1))
            
            var count = 0
            
            let g = DispatchGroup()
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
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
            
            once.subscribe(sub)
            
            g.wait()
            
            expect(count).to(equal(1))
        }
    }
}
