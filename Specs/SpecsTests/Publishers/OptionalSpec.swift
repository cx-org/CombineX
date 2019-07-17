import Dispatch
import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class OptionalSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send a value then send finished
            it("should send value then send finished") {
                let pub = Publishers.Optional<Int, CustomError>(1)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
            
            // MARK: 1.2 should send finished even no demand
            it("should send finished") {
                let pub = Publishers.Optional<Int, CustomError>(nil)
             
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .none)
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.finished)]))
            }
            
            // MARK: 1.3 should send failure even no demand
            it("should send failure") {
                let pub = Publishers.Optional<Int, CustomError>(.e0)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .none)
                pub.subscribe(sub)
                
                expect(sub.events).to(equal([.completion(.failure(.e0))]))
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.4 should throw assertion when none demand is requested
            it("should throw assertion when less than one demand is requested") {
                let pub = Publishers.Optional<Int, CustomError>(1)
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .none)
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 1.5 should throw assertion when none demand is requested even after completion
            it("should throw assertion when less than one demand is requested even after completion") {
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
                    subscription?.request(.none)
                }.to(throwAssertion())
            }
            #endif
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
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    subObj = sub
                    pub.subscribe(sub)
                }
                
                expect(subObj).toNot(beNil())
                subscription?.request(.unlimited)
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
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    
                    subObj = sub
                    pub.subscribe(sub)
                }
                
                expect(subObj).toNot(beNil())
                subscription?.cancel()
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
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    
                    pub.subscribe(sub)
                }
                
                expect(customObj).toNot(beNil())
                subscription?.request(.unlimited)
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
            
            // MARK: 3.1 should only send only one value even if the subscription requests it multiple times concurrently
            it("should only send only one value even if the subscription requests it multiple times concurrently") {
                var subscription: Subscription?
                
                let pub = Publishers.Optional<Int, Never>(1)
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let g = DispatchGroup()
                for _ in 0..<100 {
                    DispatchQueue.global().async(group: g) {
                        subscription?.request(.max(1))
                    }
                }
                g.wait()
                
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
        }
    }
}
