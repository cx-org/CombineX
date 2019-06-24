import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class FilterSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should filter from upstream
        it("should filter from upstream") {
            let pub = PassthroughSubject<Int, Never>()
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.unlimited)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.filter { $0 % 2 == 0 }.subscribe(sub)
            
            let nums = [1, 2, 3, 4, 5]
            for num in nums {
                pub.send(num)
            }
            
            let events = sub.events
            expect(events).to(equal([.value(2), .value(4)]))
        }
        
        // MARK: It should receive value as demand
        it("should receive value as demand") {
            let pub = PassthroughSubject<Int, Never>()
            
            let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                s.request(.max(10))
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
            
            pub.filter { $0 % 2 == 0 }.subscribe(sub)
            
            let nums = Array(1..<100)
            for num in nums {
                pub.send(num)
            }
            
            let events = sub.events
            expect(events.count).to(equal(10))
        }
    }
}

