import CXShim
import Quick
import Nimble

class AnySubscriberSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Subject
        describe("Subject") {
            
            // MARK: 1.1 should cancel the new subscription if there is already one
            it("should cancel the new subscription if there is already one") {
                let subject = PassthroughSubject<Int, Error>()
                let sub = AnySubscriber(subject)
                
                let s0 = TestSubscription(name: "s0")
                let s1 = TestSubscription(name: "s1")
                
                sub.receive(subscription: s0)
                sub.receive(subscription: s1)
                
                expect(s0.events).to(equal([]))
                expect(s1.events).to(equal([.cancel]))
            }
            
            // MARK: 1.2 should request none when receive values
            it("should request none when receive values") {
                let subject = PassthroughSubject<Int, Error>()
                let sub = AnySubscriber(subject)

                sub.receive(subscription: TestSubscription())

                expect(sub.receive(1)).to(equal(.max(0)))
            }
            
            // MARK: 1.3 should not cancel subscription when receive completion
            it("should not cancel subscription when receive completion") {
                let subject = PassthroughSubject<Int, TestError>()
                let sub = AnySubscriber(subject)
                
                let subscription = TestSubscription()
                sub.receive(subscription: subscription)
                
                sub.receive(completion: .finished)
                expect(subscription.events).to(equal([]))
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.4 should fatal error when receiving values before receiving a subscription
            it("should fatal error when receiving values before receiving a subscription") {
                let subject = PassthroughSubject<Int, Error>()
                let sub = AnySubscriber(subject)
                expect {
                    _ = sub.receive(1)
                }.to(throwAssertion())
            }
            
            // MARK: 1.5 should fatal error when receiving completion before receiving a subscription
            it("should fatal error when receiving completion before receiving a subscription") {
                let subject = PassthroughSubject<Int, Error>()
                let sub = AnySubscriber(subject)
                expect {
                    sub.receive(completion: .finished)
                }.to(throwAssertion())
            }
            #endif
        }
    }
}
