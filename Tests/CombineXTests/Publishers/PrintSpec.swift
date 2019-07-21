import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class PrintSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Print
        describe("Print") {
            
            // MARK: 1.1 should print cancel even if the sub is completed
            it("should print cancel even if the sub is completed") {
                let stream = Stream()
                
                let subject = PassthroughSubject<Int, CustomError>()
                let pub = subject.print("[Q]", to: stream)
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    subscription = s
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)

                subscription?.cancel()
                subject.send(completion: .finished)
                subscription?.cancel()
                
                let count = stream.outputs.count(of: "[Q]: receive cancel")
                expect(count).to(equal(2))
            }
            
            // MARK: 1.2 should print request demand even if the sub is completed
            it("should print request demand even if the sub is completed") {
                let stream = Stream()
                
                let subject = PassthroughSubject<Int, CustomError>()
                let pub = subject.print("[Q]", to: stream)
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    subscription = s
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                subscription?.request(.max(1))
                subject.send(completion: .finished)
                subscription?.request(.max(1))
                
                let count = stream.outputs.count(of: "[Q]: request max: (1)")
                expect(count).to(equal(2))
            }
            
            // MARK: 1.3 should not print events after complete
            it("should not print events after complete") {
                let stream = Stream()
                
                let subject = PassthroughSubject<Int, CustomError>()
                let pub = subject.print("[Q]", to: stream)
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    subscription = s
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                subscription?.request(.unlimited)
                
                subject.send(completion: .failure(.e0))
                subject.send(1)
                subject.send(completion: .finished)

                let outputs = stream.outputs
                let valueEventsCount = outputs.filter({ $0.starts(with: "[Q]: receive value") }).count
                let finishEventsCount = outputs.filter({ $0.starts(with: "[Q]: receive finished") }).count
                
                expect(valueEventsCount).to(equal(0))
                expect(finishEventsCount).to(equal(0))
            }
            
            // MARK: 1.2 should print as expect
            it("should print as expect") {
                
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
                
                subject.send(0)
                subject.send(completion: .finished)
                
                subscription?.cancel()
                
                let expected = ["", "[Q]: receive subscription: (PassthroughSubject)", "\n", "", "[Q]: request unlimited", "\n", "", "[Q]: receive value: (0)", "\n", "", "[Q]: request max: (1) (synchronous)", "\n", "", "[Q]: receive finished", "\n", "", "[Q]: receive cancel", "\n"]
                expect(stream.outputs).to(equal(expected))
            }
        }
    }
}

private class Stream: TextOutputStream {
    private var _outputs: [String] = []
    let lock = Lock()
    
    var outputs: [String] {
        return self.lock.withLockGet(self._outputs)
    }
    
    var string: String {
        return self.outputs.joined()
    }
    
    func write(_ string: String) {
        lock.withLock {
            self._outputs.append(string)
        }
    }
}
