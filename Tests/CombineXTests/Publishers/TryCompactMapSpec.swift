import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class TryCompactMapSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Relay
        describe("Relay") {

            // MARK: 1.1 should compact map values from upstream
            it("should compact map values from upstream") {
                let pub = PassthroughSubject<Int, TestError>()
                
                let sub = pub
                    .tryCompactMap { $0 % 2 == 0 ? $0 : nil }
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                pub.send(completion: .finished)
                
                let valueEvents = (0..<50).map { $0 * 2 }.map(TracingSubscriber<Int, Never>.Event.value)
                let expected = valueEvents + [.completion(.finished)]
                
                let got = sub.eventsWithoutSubscription.map {
                    $0.mapError { _ -> Never in
                        fatalError("never happen")
                    }
                }
                
                expect(got) == expected
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = pub
                    .tryCompactMap { $0 % 2 == 0 ? $0 : nil }
                    .subscribeTracingSubscriber(initialDemand: .max(10))
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.eventsWithoutSubscription.count) == 10
            }
            
            // MARK: 1.3 should fail if transform throws an error
            it("should fail if transform throws an error") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = pub.tryCompactMap { v -> Int in
                    if v == 10 {
                        throw TestError.e0
                    }
                    return v
                }.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                let valueEvents = (0..<10).map(TracingSubscriber<Int, TestError>.Event.value)
                let expected = valueEvents + [.completion(.failure(.e0))]
                
                let got = sub.eventsWithoutSubscription.mapError { $0 as! TestError }
                
                expect(got) == expected
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.4 should throw assertion when upstream send values before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    _ = s.receive(1)
                }
                let pub = upstream.tryCompactMap { $0 }
                
                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.to(throwAssertion())
            }
            
            // MARK: 1.5 should throw assertion when upstream send completion before sending subscription
            it("should throw assertion when upstream send values before sending subscription") {
                let upstream = AnyPublisher<Int, TestError> { s in
                    s.receive(completion: .finished)
                }
                let pub = upstream.tryCompactMap { $0 }

                expect {
                    pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                }.to(throwAssertion())
            }
            #endif
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should not release downstream and transform closure after finish
            it("subscription should not release downstream and transform closure after finish") {
                weak var downstreamObj: AnyObject?
                weak var closureObj: NSObject?
                
                var subscription: Subscription?
                
                do {
                    let testPub = AnyPublisher<Int, TestError> { s in
                        s.receive(subscription: Subscriptions.empty)
                        s.receive(completion: .finished)
                    }
                    
                    let obj = NSObject()
                    closureObj = obj
                    
                    let sub = TracingSubscriber<Int, Error>(receiveSubscription: { s in
                        subscription = s
                    })
                    downstreamObj = sub
                    
                    testPub.tryCompactMap { i -> Int in
                        withExtendedLifetime(obj) {}
                        return i
                    }.subscribe(sub)
                }
                
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
                
                _ = subscription
            }
            
            // MARK: 2.3 subscription should not release downstream and transform closure after cancel
            it("subscription should not release downstream and transform closure after cancel") {
                weak var downstreamObj: AnyObject?
                weak var closureObj: NSObject?
                
                var subscription: Subscription?
                
                do {
                    let testPub = AnyPublisher<Int, TestError> { s in
                        s.receive(subscription: Subscriptions.empty)
                    }
                    
                    let obj = NSObject()
                    closureObj = obj
                    
                    let sub = TracingSubscriber<Int, Error>(receiveSubscription: { s in
                        subscription = s
                    })
                    downstreamObj = sub
                    
                    testPub.tryCompactMap { i -> Int in
                        withExtendedLifetime(obj) {}
                        return i
                    }.subscribe(sub)
                }
                
                subscription?.cancel()
                expect(downstreamObj).toNot(beNil())
                expect(closureObj).toNot(beNil())
                
                _ = subscription
            }
        }
    }
}
