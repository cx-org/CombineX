import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class MapErrorSpec: QuickSpec {
    
    override func spec() {
        
        func makeCustomSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> CustomSubscriber<Input, Failure> {
            return CustomSubscriber<Input, Failure>(receiveSubscription: { (s) in
                s.request(demand)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
        }
        
        // MARK: Relay
        describe("Relay") {
            
            // MARK: 1.1 should map error
            it("should map error") {
                typealias Sub = CustomSubscriber<Int, CustomError>
                
                let pub = PassthroughSubject<Int, CustomError>()
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.mapError { _ in .e2 }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .failure(.e0))
                
                let events = (0..<100).map { Sub.Event.value($0) }
                let expected = events + [.completion(.failure(.e2))]
                expect(sub.events).to(equal(expected))
            }
            
        }
        
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should retain upstream, downstream and transform closure then only release upstream after upstream send finish
            it("subscription should retain upstream, downstream and transform closure then only release upstream after upstream send finish") {
                
                weak var upstreamObj: PassthroughSubject<Int, CustomError>?
                weak var downstreamObj: AnyObject?
                weak var closureObj: CustomObject?
                
                var subscription: Subscription?
                
                do {
                    let subject = PassthroughSubject<Int, CustomError>()
                    upstreamObj = subject
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let pub = subject.mapError { _ -> CustomError in
                        obj.run()
                        return .e2
                    }
                    
                    let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                        subscription = s
                        s.request(.max(1))
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    downstreamObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(upstreamObj).toNot(beNil())
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
                
                upstreamObj?.send(completion: .finished)
                
                expect(upstreamObj).to(beNil())
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.2 subscription should retain upstream, downstream and transform closure then only release upstream after cancel
            it("subscription should retain upstream, downstream and transform closure then only release upstream after cancel") {
                
                weak var upstreamObj: AnyObject?
                weak var downstreamObj: AnyObject?
                
                weak var closureObj: CustomObject?
                
                var subscription: Subscription?
                
                do {
                    let subject = PassthroughSubject<Int, CustomError>()
                    upstreamObj = subject
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let pub = subject.mapError { _ -> CustomError in
                        obj.run()
                        return .e2
                    }
                    
                    let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                        subscription = s
                        s.request(.max(1))
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    downstreamObj = sub
                    
                    pub.subscribe(sub)
                }
                
                expect(upstreamObj).toNot(beNil())
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
                
                subscription?.cancel()
                
                expect(upstreamObj).to(beNil())
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
            }
        }
    }
}
