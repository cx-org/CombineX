import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class TryCompactMapSpec: QuickSpec {
    
    override func spec() {
        
        it("should try compact value from upstream") {
            let pub = PassthroughSubject<Int, Never>()
            
            let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
            
            let nums = [1, 2, 3, 4, 5]
            for num in nums {
                pub.send(num)
            }
            
            let events = sub.events
            expect(events.count).to(equal(2))
        }
        
        it("should receive value as demand") {
            let pub = PassthroughSubject<Int, Never>()
            
            let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                s.request(.max(10))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
            
            let nums = Array(1..<100)
            for num in nums {
                pub.send(num)
            }
            
            let events = sub.events
            expect(events.count).to(equal(10))
        }
        
        it("should receive complection if an error is thrown") {
            let pub = PassthroughSubject<Int, Never>()
            
            let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                s.request(.max(100))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.tryCompactMap {
                if $0 == 50 {
                    throw CustomError.e1
                } else {
                    return $0
                }
            }.subscribe(sub)
            
            let nums = Array(1..<100)
            for num in nums {
                pub.send(num)
            }
            
            let events = sub.events
            expect(events.count).to(equal(50))
            
            guard let last = events.last else {
                fail("events should not be nil")
                return
            }
            switch last {
            case .completion(.failure(let e)):
                expect(e).to(matchError(CustomError.e1))
            default:
                fail("last event should be an error")
            }
        }
    }
}
