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
    }
}
