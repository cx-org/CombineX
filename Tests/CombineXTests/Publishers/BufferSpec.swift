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
            
            fit("buffer") {
                let subject = TestSubject<Int, TestError>(name: "buffer")
                subject.isLogEnabled = true
                let pub = subject.buffer(size: 9, prefetch: .keepFull, whenFull: .dropOldest)
                
                var subscription: Subscription?
                let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                    subscription = s
                    s.request(.max(1))
                }, receiveValue: { v in
                    print("receive v", v)
                    return .none
                }, receiveCompletion: { c in
                    print("receive c", c)
                })
                
                pub.subscribe(sub)
                20.times {
                    print("send", $0)
                    subject.send($0)
                }
                subscription?.request(.max(5))
                subscription?.request(.max(5))
            }
            
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
