import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class BufferSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should relay values as expect when prefetch strategy is by request
            fit("should relay values as expect when prefetch strategy is by request") {
                let pub = CustomSubject<Int, CustomError>()
                
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    print("sub receive", v)
                    return v == 0 ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                
                pub.buffer(size: 2, prefetch: .byRequest, whenFull: .dropOldest)
                    .subscribe(sub)
                
                for i in 0..<5 {
                    print("pub send", i)
                    pub.send(i)
                }
                
                expect(sub.events).to(equal([.value(0), .value(1)]))
                
                subscription?.request(.max(1))
                subscription?.request(.max(1))
                
                for i in 5..<10 {
                    print("pub send", i)
                    pub.send(i)
                }
                
                expect(sub.events).to(equal([.value(0), .value(1), .value(3), .value(4)]))
            }
            
            // MARK: 1.2 should relay values as expect when prefetch strategy is keep full
            it("should relay values as expect when prefetch strategy is keep full") {
                let pub = CustomSubject<Int, CustomError>()
                
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    print("sub receive", v)
                    return v == 0 ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                
                pub.buffer(size: 5, prefetch: .keepFull, whenFull: .dropOldest)
                    .subscribe(sub)
                
                for i in 0..<10 {
                    print("pub send", i)
                    pub.send(i)
                }
                
                print(sub.events)
//                expect(sub.events).to(equal([.value(0), .value(1)]))
                
                subscription?.request(.max(1))
                subscription?.request(.max(1))
                
                for i in 10..<20 {
                    pub.send(i)
                }
                
                print(sub.events)
//                expect(sub.events).to(equal([.value(0), .value(1), .value(3), .value(4)]))
            }
        }
    }
}

/*
 request demand max(5)
 request demand max(1)
 receive value 0 request more max(1)
 receive value 1 request more max(1)
 receive value 2 request more max(0)
 receive value 3 request more max(0)
 receive value 4 request more max(0)
 receive value 5 request more max(0)
 receive value 6 request more max(0)
 receive value 7 request more max(0)
 [0, 1]
 request demand max(2)
 request demand max(2)
 receive value 10 request more max(0)
 receive value 11 request more max(0)
 receive value 12 request more max(0)
 receive value 13 request more max(0)
 [0, 1, 3, 4]
 
 ***********************************
 
 request demand unlimited
 request demand max(1)
 receive value 0 request more max(0)
 receive value 1 request more max(0)
 receive value 2 request more max(0)
 receive value 3 request more max(0)
 receive value 4 request more max(0)
 [0, 1]
 request demand max(1)
 request demand max(1)
 receive value 5 request more max(0)
 receive value 6 request more max(0)
 receive value 7 request more max(0)
 receive value 8 request more max(0)
 receive value 9 request more max(0)
 [0, 1, 3, 4]
 */
