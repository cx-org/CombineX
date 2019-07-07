import Foundation
import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class SequenceSpec: QuickSpec {
    
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
            typealias Sub = CustomSubscriber<Int, CustomError>
            
            // MARK: 1.1 should send values then send finished
            it("should send values then send finished") {
                let array = Array(0..<100)
                let pub = Publishers.Sequence<[Int], CustomError>(sequence: array)
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                
                pub.subscribe(sub)
                
                let events = array.map { Sub.Event.value($0) }
                let expected = events + [.completion(.finished)]
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.2
            it("should send as many values as demand") {
                let array = Array(0..<100)
                let pub = Publishers.Sequence<[Int], CustomError>(sequence: array)
                
                let sub = CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    s.request(.max(50))
                }, receiveValue: { v in
                    return v == 10 ? .max(10) : .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let events = (0..<60).map { Sub.Event.value($0) }
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
                    let array = Array(0..<10)
                    let pub = Publishers.Sequence<[Int], Never>(sequence: array)
                    
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
                    let array = Array(0..<10)
                    let pub = Publishers.Sequence<[Int], Never>(sequence: array)
                    
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
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 3.1 should send as many values as demand even if these are concurrently requested
            it("should send as many values as demand even if these are concurrently requested") {
                typealias Sub = CustomSubscriber<Int, Never>
                
                struct Seq: Sequence, IteratorProtocol {
                    var current = 0
                    mutating func next() -> Int? {
                        defer {
                            current += 1
                        }
                        return current
                    }
                }
            
                let g = DispatchGroup()
                let pub = Publishers.Sequence<Seq, Never>(sequence: Seq())
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
                
                expect(sub.events).to(equal((0..<100).map { Sub.Event.value($0) }))
            }
        }
    }

}
