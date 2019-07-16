import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class SequenceSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            typealias Sub = CustomSubscriber<Int, CustomError>
            typealias Event = CustomEvent<Int, CustomError>
            
            // MARK: 1.1 should send values then send finished
            it("should send values then send finished") {
                let values = Array(0..<100)
                let pub = Publishers.Sequence<[Int], CustomError>(sequence: values)
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                let valueEvents = values.map { Event.value($0) }
                let expected = valueEvents + [.completion(.finished)]
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let values = Array(0..<100)
                
                let pub = Publishers.Sequence<[Int], CustomError>(sequence: values)
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    s.request(.max(50))
                }, receiveValue: { v in
                    [0, 10].contains(v) ? .max(10) : .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let events = (0..<70).map { Event.value($0) }
                expect(sub.events).to(equal(events))
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should release the subscriber after complete
            it("subscription should release the subscriber after complete") {
                var subscription: Subscription?
                weak var subObj: AnyObject?
                
                do {
                    let values = Array(0..<10)
                    let pub = Publishers.Sequence<[Int], Never>(sequence: values)
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
                    let values = Array(0..<10)
                    let pub = Publishers.Sequence<[Int], Never>(sequence: values)
                    
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
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            struct Seq: Sequence, IteratorProtocol {
                var val = 0
                mutating func next() -> Int? {
                    defer {
                        val += 1
                    }
                    return val
                }
            }
            
            // MARK: 3.1 should send as many values as demand even if these are concurrently requested
            it("should send as many values as demand even if these are concurrently requested") {
                let g = DispatchGroup()
                let pub = Publishers.Sequence<Seq, Never>(sequence: Seq())
                
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                for _ in 0..<10 {
                    DispatchQueue.global().async(group: g) {
                        subscription?.request(.max(1))
                    }
                }
            
                g.wait()
                
                let events = equal((0..<10).map { CustomEvent<Int, Never>.value($0) })
                expect(sub.events).to(events)
            }
            
            // MARK: 3.2 receiving value should not block cancel
            fit("receiving value should not block") {
                let pub = Publishers.Sequence<Seq, Never>(sequence: Seq())
                
                var subscription: Subscription?
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                    subscription = s
                }, receiveValue: { v in
                    Thread.sleep(forTimeInterval: 0.1)
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let status = Atom(0)
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    subscription?.cancel()
                    status.set(2)
                }
                
                subscription?.request(.max(5))
                status.set(1)
                
                expect(status.get()).to(equal(1))
            }
        }
    }

}
