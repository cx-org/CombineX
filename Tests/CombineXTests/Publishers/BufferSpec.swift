import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class BufferSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should relay values as expect when prefetch strategy is by request
            xit("should relay values as expect when prefetch strategy is by request") {
                let pub = PassthroughSubject<Int, TestError>()
                
                var subscription: Subscription?
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    print("sub receive", v)
                    switch v {
                    case 0:     return .max(1)
                    case 5:     return .max(1)
                    default:    return .none
                    }
                }, receiveCompletion: { c in
                })
                
                pub.buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
                    .subscribe(sub)
                
                for i in 0..<10 {
                    print("pub send", i)
                    pub.send(i)
                }
                
                print(sub.events)
//                expect(sub.events).to(equal([.value(0), .value(1)]))
                
                print("subscription want more", 1)
                subscription?.request(.max(1))
                print("subscription want more", 1)
                subscription?.request(.max(1))
                
                for i in 10..<20 {
                    print("pub send", i)
                    pub.send(i)
                }
                
                print(sub.events)
//                expect(sub.events).to(equal([.value(0), .value(1), .value(3), .value(4)]))
            }
            
            // MARK: 1.2 should relay values as expect when prefetch strategy is keep full
            xit("should relay values as expect when prefetch strategy is keep full") {
                let pub = PassthroughSubject<Int, TestError>()
                
                var subscription: Subscription?
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    print("sub receive", v)
                    switch v {
                    case 0:     return .max(1)
                    case 5:     return .max(1)
                    default:    return .none
                    }
                }, receiveCompletion: { c in
                })
                
                pub.buffer(size: 10, prefetch: .keepFull, whenFull: .dropOldest)
                    .subscribe(sub)
                
                for i in 0..<10 {
                    print("pub send", i)
                    pub.send(i)
                }
                
                print(sub.events)
//                expect(sub.events).to(equal([.value(0), .value(1)]))
                print("subscription request more", 5)
                subscription?.request(.max(5))
                print("subscription request more", 3)
                subscription?.request(.max(3))
                
                for i in 10..<30 {
                    pub.send(i)
                }
                
                print(sub.events)
//                expect(sub.events).to(equal([.value(0), .value(1), .value(3), .value(4)]))
            }
        }
    }
}

/*
 request demand unlimited
 request demand max(1)
 pub send 0
 sub receive 0
 receive value 0 request more max(0)
 pub send 1
 sub receive 1
 receive value 1 request more max(0)
 pub send 2
 receive value 2 request more max(0)
 pub send 3
 receive value 3 request more max(0)
 pub send 4
 receive value 4 request more max(0)
 pub send 5
 receive value 5 request more max(0)
 pub send 6
 receive value 6 request more max(0)
 pub send 7
 receive value 7 request more max(0)
 pub send 8
 receive value 8 request more max(0)
 pub send 9
 receive value 9 request more max(0)
 [0, 1]
 subscription want more 1
 sub receive 5
 sub receive 6
 request demand max(1)
 subscription want more 1
 sub receive 7
 request demand max(1)
 pub send 10
 receive value 10 request more max(0)
 pub send 11
 receive value 11 request more max(0)
 pub send 12
 receive value 12 request more max(0)
 pub send 13
 receive value 13 request more max(0)
 pub send 14
 receive value 14 request more max(0)
 pub send 15
 receive value 15 request more max(0)
 pub send 16
 receive value 16 request more max(0)
 pub send 17
 receive value 17 request more max(0)
 pub send 18
 receive value 18 request more max(0)
 pub send 19
 receive value 19 request more max(0)
 [0, 1, 5, 6, 7]
 
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
