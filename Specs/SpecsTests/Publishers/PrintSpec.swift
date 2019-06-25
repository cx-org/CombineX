import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class PrintSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: It should print as expect
        it("should print as expect") {
            
            class Stream: TextOutputStream {
                var output = ""
                func write(_ string: String) {
                    self.output.append(string)
                }
            }
            
            let stream = Stream()
            
            let subject = PassthroughSubject<Int, CustomError>()
            let pub = subject.print("[Q]", to: stream)
            
            var subscription: Subscription?
            let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                s.request(.unlimited)
                subscription = s
            }, receiveValue: { v in
                return .max(1)
            }, receiveCompletion: { c in
            })
            
            pub.subscribe(sub)
            
            2.times {
                subject.send($0)
            }
            subject.send(completion: .finished)
            subject.send(completion: .finished)
            
            subscription?.cancel()
            
            let expected = """
            [Q]: receive subscription: (PassthroughSubject)
            [Q]: request unlimited
            [Q]: receive value: (0)
            [Q]: request max: (1) (synchronous)
            [Q]: receive value: (1)
            [Q]: request max: (1) (synchronous)
            [Q]: receive finished
            [Q]: receive cancel
            
            """
            expect(stream.output).to(equal(expected))
        }
        
        // MARK: It should release upstream but not release stream and sub when finished
        it("should release upstream but not release stream and sub when finished") {
            
            class Null: TextOutputStream {
                func write(_ string: String) {
                }
            }
            
            weak var pubObj: PassthroughSubject<Int, Never>?
            weak var streamObj: AnyObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                pubObj = subject
                
                let stream = Null()
                streamObj = stream
                
                let pub = subject.print("😈", to: stream)
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
            expect(streamObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            pubObj?.send(completion: .finished)
            
            // FIXME: `Print` doesn't seems to release subscriber?
            expect(pubObj).to(beNil())
            expect(streamObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            _ = subscription
        }
        
        // MARK: It should release upstream but not release stream and sub when cancelled.
        it("should release upstream but not release stream and sub when cancelled") {
            
            class Null: TextOutputStream {
                func write(_ string: String) {
                }
            }
            
            weak var pubObj: PassthroughSubject<Int, Never>?
            weak var streamObj: AnyObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                pubObj = subject
                
                let stream = Null()
                streamObj = stream
                
                let pub = subject.print("😈", to: stream)
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
            expect(streamObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            subscription?.cancel()
            
            expect(pubObj).to(beNil())

            // FIXME: `Print` doesn't seems to release subscriber?
            expect(streamObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            _ = subscription
        }
    }
}
