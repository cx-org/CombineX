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

class FlatMapSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should send sub-subscriber's value
            it("should send sub-subscriber's value") {
                typealias Sub = CustomSubscriber<Int, Never>
                
                let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3])
                
                let pub = sequence
                    .flatMap {
                        Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                    }
                
                let sub = Sub(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let events = [1, 2, 3].flatMap { [$0, $0, $0] }.map { Sub.Event.value($0) }
                let expected = events + [.completion(.finished)]
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.2 should send values as demand
            it("should send values as demand") {
                let sequence = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4, 5])
                
                let pub = sequence
                    .flatMap {
                        Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                    }
                    .flatMap {
                        Publishers.Sequence<[Int], Never>(sequence: [$0, $0, $0])
                    }
                
                var received = 0
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(1))
                }, receiveValue: { v in
                    received += 1
                    return received == 10 ? .none : .max(1)
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                expect(sub.events.count).to(equal(received))
            }
            
            // MARK: 1.3 should complete when a sub-publisher sends an error
            it("should complete when a sub-publisher sends an error") {
                typealias Sub = CustomSubscriber<Int, CustomError>
                
                let sequence = Publishers.Sequence<[Int], CustomError>(sequence: [0, 1, 2])
                
                let subjects = [
                    PassthroughSubject<Int, CustomError>(),
                    PassthroughSubject<Int, CustomError>(),
                    PassthroughSubject<Int, CustomError>(),
                ]
                
                let pub = sequence
                    .flatMap {
                        subjects[$0]
                    }
                
                let sub = Sub(receiveSubscription: { s in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                3.times {
                    subjects[0].send(0)
                    subjects[1].send(1)
                    subjects[2].send(2)
                }
                
                subjects[1].send(completion: .failure(.e1))
                
                expect(sub.events.count).to(equal(10))
                
                var events = [0, 1, 2].flatMap { _ in [0, 1, 2] }.map { Sub.Event.value($0) }
                events.append(Sub.Event.completion(.failure(.e1)))
                
                expect(sub.events).to(equal(events))
            }
            
            // MARK: 1.4 should buffer one output for each sub-publisher if there is no demand
            it("should buffer one output for each sub-publisher if there is no demand") {
                typealias Sub = CustomSubscriber<Int, Never>
                
                let subjects = [
                    PassthroughSubject<Int, Never>(),
                    PassthroughSubject<Int, Never>()
                ]
                let pub = Publishers.Sequence<[Int], Never>(sequence: [0, 1]).flatMap { subjects[$0] }
                
                var subscription: Subscription?
                let sub = Sub(receiveSubscription: { s in
                    subscription = s
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                subjects[0].send(0)
                subjects[1].send(0)
                
                subjects[0].send(1)
                subjects[1].send(1)
                
                subscription?.request(.max(2))
                
                subjects[1].send(2)
                subjects[0].send(3)
                subjects[1].send(4)
                subjects[0].send(5)
                
                subscription?.request(.unlimited)
                
                expect(sub.events).to(equal([.value(0), .value(0), .value(2), .value(3)]))
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 subscription should retain upstream, downstream and transform closure then only release upstream after upstream send finish
            it("subscription should retain upstream, downstream and transform closure then only release upstream after upstream send finish") {
                
                weak var upstreamObj: PassthroughSubject<Int, Never>?
                weak var downstreamObj: AnyObject?
                weak var closureObj: CustomObject?
                
                var subscription: Subscription?
                
                do {
                    let subject = PassthroughSubject<Int, Never>()
                    upstreamObj = subject
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let pub = subject.flatMap { _ -> Just<Int> in
                        obj.run()
                        return Just(1)
                    }
                    
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        subscription = s
                        s.request(.unlimited)
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
                    let subject = PassthroughSubject<Int, Never>()
                    upstreamObj = subject
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let pub = subject.flatMap { _ -> Just<Int> in
                        obj.run()
                        return Just(1)
                    }
                    
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
                        subscription = s
                        s.request(.unlimited)
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
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: 3.1 should send as many values ad demand event if there are sent concurrently
            fit("should send as many values ad demand event if there are sent concurrently") {
                let sequence = Publishers.Sequence<[Int], Never>(sequence: [0, 1, 2])
                
                let subjects = [
                    PassthroughSubject<Int, Never>(),
                    PassthroughSubject<Int, Never>(),
                    PassthroughSubject<Int, Never>(),
                ]
                
                let pub = sequence.flatMap { (i) -> PassthroughSubject<Int, Never> in
                    return subjects[i]
                }
                
                let sub = CustomSubscriber<Int, Never>(receiveSubscription: { s in
                    s.request(.max(10))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let g = DispatchGroup()
                
                100.times { i in
                    DispatchQueue.global().async(group: g) {
                        subjects.randomElement()!.send(i)
                    }
                }
                
                g.wait()
                
                expect(sub.events.count).to(equal(10))
            }
        }
    }
}
