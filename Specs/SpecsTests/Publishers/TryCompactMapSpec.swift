import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
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
                
                expect(sub.events.count).to(equal(51))
                for (i, event) in zip(0...50, sub.events) {
                    switch event {
                    case .value(let output):
                        expect(output).to(equal(i * 2))
                    case .completion(let completion):
                        expect(i).to(equal(50))
                        expect(completion.isFinished).to(beTrue())
                    }
                }
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .max(10))
                
                pub.tryCompactMap { $0 }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.events.count).to(equal(10))
            }
            
            // MARK: 1.3 should fail if transform throws error
            it("should fail if transform throws error") {
                let pub = PassthroughSubject<Int, CustomError>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryCompactMap {
                    if $0 == 10 {
                        throw CustomError.e0
                    } else {
                        return $0
                    }
                }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                expect(sub.events.count).to(equal(11))
                for (i, event) in zip(0...10, sub.events) {
                    switch event {
                    case .value(let output):
                        expect(output).to(equal(i))
                    case .completion(let completion):
                        expect(i).to(equal(10))
                        expect(completion.isFailure).to(beTrue())
                    }
                }
            }
            
//            fit("should ") {
//                class Pub: Publisher {
//                    typealias Output = Int
//                    typealias Failure = CustomError
//                    
//                    // /BuildRoot/Library/Caches/com.apple.xbs/Sources/PubSub_Sim/PubSub-120/Combine/Source/FilterProducer.swift
//                    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
//                        
//                        let url = URL(fileURLWithPath: "/BuildRoot/Library/Caches/com.apple.xbs/Sources/PubSub_Sim/PubSub-120/Combine/Source/FilterProducer.swift")
//                        let str = try? String(contentsOf: url)
//                        Swift.print(str)
//                        
//                        subscriber.receive(completion: .finished)
//                    }
//                }
//                
//                let pub = Pub().tryCompactMap { $0 }
//                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
//                
//                pub.subscribe(sub)
//            }
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
                    
                    let pub = subject.tryCompactMap { (v) -> Int in
                        obj.run()
                        return v
                    }
                    
                    let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
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
                    let subject = PassthroughSubject<Int, Never>()
                    upstreamObj = subject
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let pub = subject.tryCompactMap { (v) -> Int in
                        obj.run()
                        return v
                    }
                    
                    let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
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
