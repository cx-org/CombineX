import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class PrintSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Print
        describe("Print") {
            
            // MARK: 1.1 should print as expect
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
        }
    }
}
