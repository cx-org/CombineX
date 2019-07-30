import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class AnySubscriberSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            Resources.release()
        }
        
        // MARK: - Wrap
        describe("Wrap") {
            
            // MARK: 1 Wrap a subject
            context("Wrap a subject") {
                
                // MARK: 1.1 should not request demand when receive subscription
                xit("should request demand when receive subscription") {
                    let subject = PassthroughSubject<Int, Error>()
                    let sub = AnySubscriber(subject)
                    
                    var demand: Demand?
                    
                    let subscription = TestSubscription(request: {
                        demand = $0
                    }, cancel: {
                    })
                    
                    sub.receive(subscription: subscription)
                    
                    // TODO: under investigation
                    expect(demand).to(beNil())
                }
                
                // MARK: 1.2 should request none when receive values
                it("should request none when receive values") {
                    let subject = PassthroughSubject<Int, Error>()
                    let sub = AnySubscriber(subject)

                    sub.receive(subscription: TestSubscription())

                    expect(sub.receive(1)).to(equal(.max(0)))
                }
                
                // MARK: 1.3 should relay events when receive events
                it("should relay events when receive events") {
                    let subject = PassthroughSubject<Int, TestError>()
                    
                    let sub = TestSubscriber<Int, TestError>(receiveSubscription: { (s) in
                        s.request(.unlimited)
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { c in
                    })
                    
                    subject.subscribe(sub)
                    
                    let pub = PassthroughSubject<Int, TestError>()
                    pub.subscribe(AnySubscriber(subject))
                    
                    pub.send(1)
                    pub.send(2)
                    pub.send(3)
                    pub.send(completion: .finished)
                    
                    expect(sub.events).to(equal([.value(1), .value(2), .value(3), .completion(.finished)]))
                }
            }
            
            // MARK: 2 Wrap closures
            context("Wrap closures") {
                
                // MARK: 2.1 should do nothing when closures are nil
                it("should do nothing when closures are nil") {
                    let sub = AnySubscriber<Int, TestError>(receiveSubscription: nil, receiveValue: nil, receiveCompletion: nil)
                    
                    let subscription = TestSubscription(request: { (_) in
                        fail()
                    }, cancel: {
                        fail()
                    })
                    
                    sub.receive(subscription: subscription)
                    
                    expect(sub.receive(1)).to(equal(.max(0)))
                    
                    sub.receive(completion: .finished)
                    
                    expect(sub.receive(1)).to(equal(.max(0)))
                }
            }
        }
        
        // MARK: Exception
        #if !SWIFT_PACKAGE
        describe("Exception") {
            
            // MARK: 3.1 should fatal error when wrapping a subject and receiving values before receiving a subscription
            it("should fatal error when wrapping a subject and receiving values before receiving a subscription") {
                let subject = PassthroughSubject<Int, Error>()
                let sub = AnySubscriber(subject)
                expect {
                    _ = sub.receive(1)
                }.to(throwAssertion())
            }
            
            // MARK: 3.2 should fatal error when wrapping a subject and receiving completion before receiving a subscription
            it("should fatal error when wrapping a subject and receiving completion before receiving a subscription") {
                let subject = PassthroughSubject<Int, Error>()
                let sub = AnySubscriber(subject)
                expect {
                    sub.receive(completion: .finished)
                }.to(throwAssertion())
            }
        }
        #endif
    }
}
