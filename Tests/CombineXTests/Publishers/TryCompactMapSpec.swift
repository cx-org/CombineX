import CXShim
import CXTestUtility
import Nimble
import Quick

class TryCompactMapSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: Relay
        describe("Relay") {

            // MARK: 1.1 should compact map values from upstream
            it("should compact map values from upstream") {
                let pub = PassthroughSubject<Int, TestError>()
                
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                pub.send(completion: .finished)
                
                let valueEvents = (0..<50).map { TestSubscriberEvent<Int, Never>.value(2 * $0) }
                let expected = valueEvents + [.completion(.finished)]
                
                let got = sub.events.map {
                    $0.mapError { _ -> Never in
                        fatalError("never happen")
                    }
                }
                
                expect(got) == expected
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .max(10))
                
                pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.events.count) == 10
            }
            
            // MARK: 1.3 should fail if transform throws an error
            it("should fail if transform throws an error") {
                let pub = PassthroughSubject<Int, TestError>()
                
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryCompactMap {
                    if $0 == 10 {
                        throw TestError.e0
                    }
                    return $0
                }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                let valueEvents = (0..<10).map { TestSubscriberEvent<Int, TestError>.value($0) }
                let expected = valueEvents + [.completion(.failure(.e0))]
                
                let got = sub.events.mapError { $0 as! TestError }
                
                expect(got) == expected
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.4 should throw assertion when upstream send values before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                let pub = upstream.tryCompactMap { $0 }
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                expect {
                    pub.subscribe(sub)
                }.to(throwAssertion())
            }
            
            // MARK: 1.5 should throw assertion when upstream send completion before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = TestPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                let pub = upstream.tryCompactMap { $0 }
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)

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
                weak var closureObj: TestObject?
                
                var subscription: Subscription?
                
                do {
                    let testPub = TestPublisher<Int, TestError> { s in
                        s.receive(subscription: Subscriptions.empty)
                        s.receive(completion: .finished)
                    }
                    
                    let obj = TestObject()
                    closureObj = obj
                    
                    let sub = TestSubscriber<Int, Error>(receiveSubscription: { s in
                        subscription = s
                    }, receiveValue: { _ in
                        return .none
                    }, receiveCompletion: { _ in
                    })
                    downstreamObj = sub
                    
                    testPub
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
                weak var closureObj: TestObject?
                
                var subscription: Subscription?
                
                do {
                    let testPub = TestPublisher<Int, TestError> { s in
                        s.receive(subscription: Subscriptions.empty)
                    }
                    
                    let obj = TestObject()
                    closureObj = obj
                    
                    let sub = TestSubscriber<Int, Error>(receiveSubscription: { s in
                        subscription = s
                    }, receiveValue: { _ in
                        return .none
                    }, receiveCompletion: { _ in
                    })
                    downstreamObj = sub
                    
                    testPub
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
