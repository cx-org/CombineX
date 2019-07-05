import Dispatch
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class OptionalSpec: QuickSpec {
    
    override func spec() {
        
        func makeCustomSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> CustomSubscriber<Input, Failure> {
            return CustomSubscriber<Input, Failure>(receiveSubscription: { (s) in
                s.request(demand)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
        }
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send value then send finished
            it("should send value then send finished") {
                let pub = Publishers.Optional<Int, CustomError>(1)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
            
            // MARK: 1.2 should send finished
            it("should send finished") {
                let pub = Publishers.Optional<Int, CustomError>(nil)
             
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
            // MARK: 1.3 should send failure
            it("should send failure") {
                let pub = Publishers.Optional<Int, CustomError>(.e0)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should release the subscriber after complete
            it("subscription should release the subscriber after complete") {
                var subscription: Subscription?
                weak var subObj: AnyObject?
                
                do {
                    let pub = Publishers.Optional<Int, Never>(1)
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        subscription = s
                        s.request(.unlimited)
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    
                    subObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(subObj).to(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.2 subscription should release the subscriber after cancel
            it("subscription should release the subscriber after cancel") {
                var subscription: Subscription?
                weak var subObj: AnyObject?
                
                do {
                    let pub = Publishers.Optional<Int, Never>(1)
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        subscription = s
                        s.cancel()
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    
                    subObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(subObj).to(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.3 subscription should not release the initial object after complete
            it("subscription should not release the initial object after complete") {
                var subscription: Subscription?
                weak var customObj: AnyObject?
                
                do {
                    let obj = CustomObject()
                    customObj = obj
                    
                    let pub = Publishers.Optional<CustomObject, Never>(obj)
                    let sub = CustomSubscriber<CustomObject, Never>(receiveSubscription: { (s) in
                        subscription = s
                        s.request(.unlimited)
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    
                    pub.subscribe(sub)
                }
                
                expect(customObj).toNot(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.4 subscription should not release the initial object after cancel
            it("subscription should not release the initial object after cancel") {
                var subscription: Subscription?
                weak var customObj: AnyObject?
                
                do {
                    let obj = CustomObject()
                    customObj = obj
                    
                    let pub = Publishers.Optional<CustomObject, Never>(obj)
                    let sub = CustomSubscriber<CustomObject, Never>(receiveSubscription: { (s) in
                        subscription = s
                        s.request(.unlimited)
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    
                    pub.subscribe(sub)
                }

                subscription?.cancel()
                
                expect(customObj).toNot(beNil())
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 3.1 should send only one value even if the subscription request concurrently
            it("should only send only one value even if the subscription request concurrently") {
                let g = DispatchGroup()
                
                let pub = Publishers.Optional<Int, Never>(1)
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    for _ in 0..<100 {
                        DispatchQueue.global().async(group: g) {
                            s.request(.max(1))
                        }
                    }
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                g.wait()
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
        }
        
        // MARK: - Exception
        #if !SWIFT_PACKAGE
        describe("Exception") {
            
            // MARK: 4.1 should fatal error when less than one demand is requested
            it("should fatal error when less than one demand is requested") {
                let pub = Publishers.Optional<Int, CustomError>(1)
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { s in
                    s.request(.max(0))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 4.2 should fatal error when less than one demand is requested after finish
            it("should fatal error when less than one demand is requested after finish") {
                var subscription: Subscription?
                let pub = Publishers.Optional<Int, CustomError>(1)
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { s in
                    subscription = s
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                expect {
                    subscription?.request(.max(0))
                }.to(throwAssertion())
            }
        }
        #endif
    }
}
