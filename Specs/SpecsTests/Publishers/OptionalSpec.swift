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
            
            // MARK: * should send value then send finished
            it("should send value then send finished") {
                let pub = Publishers.Optional<Int, CustomError>(1)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
            
            // MARK: * should send finished
            it("should send finished") {
                let pub = Publishers.Optional<Int, CustomError>(nil)
             
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
            // MARK: * should send failure
            it("should send failure") {
                let pub = Publishers.Optional<Int, CustomError>(.e0)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: * should release the subscriber when complete
            it("should release the subscriber when complete") {
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
            
            // MARK: * should not release the initial object when complete
            it("should not release the initial object when complete") {
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
            
            // MARK: * should not release the initial object when cancel
            it("should not release the initial object when cancel") {
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
                
                subscription?.cancel()
                
                expect(customObj).toNot(beNil())
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: * should send only one value even if the subscription request concurrently
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
            
            // MARK: * should fatal error when less than one demand is requested
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
        }
        #endif
    }
}
