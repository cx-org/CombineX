import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class TryCompactMapSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Relay
        describe("Relay") {
            
            // MARK: 1.1 should compact map values from upstream
            it("should compact map values from upstream") {
                let pub = PassthroughSubject<Int, CustomError>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                pub.send(completion: .finished)
                
                let valueEvents = (0..<50).map { CustomEvent<Int, Never>.value(2 * $0) }
                let expected = valueEvents + [.completion(.finished)]
                
                let got = sub.events.map {
                    $0.mapError { _ -> Never in
                        fatalError("never happen")
                    }
                }
                
                expect(got).to(equal(expected))
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .max(10))
                
                pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.events.count).to(equal(10))
            }
            
            // MARK: 1.3 should fail if transform throws an error
            it("should fail if transform throws an error") {
                let pub = PassthroughSubject<Int, CustomError>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryCompactMap {
                    if $0 == 10 {
                        throw CustomError.e0
                    }
                    return $0
                }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                let valueEvents = (0..<10).map { CustomEvent<Int, CustomError>.value($0) }
                let expected = valueEvents + [.completion(.failure(.e0))]
                
                let got = sub.events.map {
                    $0.mapError { e -> CustomError in
                        e as! CustomError
                    }
                }
                
                expect(got).to(equal(expected))
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.4 should throw assertion when upstream send values before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = CustomPublisher<Int, CustomError> { s in
                    _ = s.receive(1)
                }
                
                let pub = upstream.tryCompactMap { $0 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 1.5 should throw assertion when upstream send completion before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = CustomPublisher<Int, CustomError> { s in
                    s.receive(completion: .finished)
                }
                
                let pub = upstream.tryCompactMap { $0 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)

                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            #endif
        }
        
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should not release downstream and transform closure after finish
            it("subscription should not release downstream and transform closure after finish") {
                weak var downstreamObj: AnyObject?
                weak var closureObj: CustomObject?
                
                var subscription: Subscription?
                
                do {
                    let customPub = CustomPublisher<Int, CustomError> { (s) in
                        s.receive(subscription: Subscriptions.empty)
                        s.receive(completion: .finished)
                    }
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                        subscription = s
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    downstreamObj = sub
                    
                    customPub
                        .tryCompactMap { i -> Int in
                            obj.run()
                            return i
                    }
                    .subscribe(sub)
                }
                
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.3 subscription should not release downstream and transform closure after cancel
            it("subscription should not release downstream and transform closure after cancel") {
                weak var downstreamObj: AnyObject?
                weak var closureObj: CustomObject?
                
                var subscription: Subscription?
                
                do {
                    let customPub = CustomPublisher<Int, CustomError> { (s) in
                        s.receive(subscription: Subscriptions.empty)
                    }
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                        subscription = s
                    }, receiveValue: { v in
                        return .none
                    }, receiveCompletion: { s in
                    })
                    downstreamObj = sub
                    
                    customPub
                        .tryCompactMap { i -> Int in
                            obj.run()
                            return i
                        }
                        .subscribe(sub)
                }
                
                subscription?.cancel()
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
                
                _ = subscription
            }
        }

    }
}
