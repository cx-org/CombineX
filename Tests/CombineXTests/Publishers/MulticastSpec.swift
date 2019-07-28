import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class MulticastSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            Resources.release()
        }
        
        describe("Relay") {
            
            // MARK: 1.1 should multicase after connect
            it("should multicase after connect") {
                let subject = PassthroughSubject<Int, TestError>()
                let pub = subject.multicast(subject: PassthroughSubject<Int, TestError>())
                
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                10.times {
                    subject.send($0)
                }
                expect(sub.events).to(equal([]))
                
                let cancel = pub.connect()
                
                10.times {
                    subject.send($0)
                }
                expect(sub.events).to(equal((0..<10).map { .value($0) }))
                
                cancel.cancel()
                
                10.times {
                    subject.send($0)
                }
                
                expect(sub.events).to(equal((0..<10).map { .value($0) }))
            }
        }
    }
}
