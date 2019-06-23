import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class AppendableString: TextOutputStream {
    
    var string: String = ""
    
    func write(_ string: String) {
        self.string += string
    }
}

class PrintSpec: QuickSpec {
    
    override func spec() {
        
        it("should print as expect") {
            
            let output = AppendableString()
            
            let subject = PassthroughSubject<Int, CustomError>()
            let pub = subject.print("[Q]", to: output)
            
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

            expect(output.string).to(equal(expected))
        }
        
        it("should output to console if stream is nil") {
            let subject = PassthroughSubject<Int, CustomError>()
            let pub = subject.print("[Q]", to: nil)
            
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
        }
        
        it("should release pub and sub when finished") {
            
            class Stream: TextOutputStream {
                func write(_ string: String) {
                    print(string, terminator: "")
                }
            }
            
            weak var pubObj: PassthroughSubject<Int, Never>?
            weak var streamObj: AnyObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                pubObj = subject
                
                let stream = Stream()
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
            
            expect(pubObj).to(beNil())

            expect(streamObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            _ = subscription
        }
        
        fit("should release pub and sub when cancel") {
            
            class Stream: TextOutputStream {
                func write(_ string: String) {
                    print(string, terminator: "")
                }
            }
            
            weak var pubObj: PassthroughSubject<Int, Never>?
            weak var streamObj: AnyObject?
            weak var subObj: AnyObject?
            
            var subscription: Subscription?
            
            do {
                let subject = PassthroughSubject<Int, Never>()
                pubObj = subject
                
                let stream = Stream()
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
            
            expect(streamObj).toNot(beNil())
            expect(subObj).toNot(beNil())
            
            _ = subscription
        }
    }
}
