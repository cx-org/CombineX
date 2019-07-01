import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class TryCompactMapSpec: QuickSpec {
    
    override func spec() {
        
        func makeCustomSubscriber<Input, Failure: Error>(_ input: Input.Type, _ failure: Failure.Type, _ demand: Subscribers.Demand) -> CustomSubscriber<Input, Failure> {
            return CustomSubscriber<Input, Failure>(receiveSubscription: { (s) in
                s.request(demand)
            }, receiveValue: { v in
                return .none
            }, receiveCompletion: { c in
            })
        }
        
        // MARK: Transform Values
        describe("Transform Values") {
            
            // MARK: * should compact map values from upstream
            it("should compact map values from upstream") {
                let pub = PassthroughSubject<Int, CustomError>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                pub.send(completion: .finished)
                
                expect(sub.events.count).to(equal(51))
                for (i, event) in zip(0..<50, sub.events) {
                    switch event {
                    case .value(let output):
                        expect(output).to(equal(i * 2))
                    case .completion(let completion):
                        expect(completion.isFinished).to(beTrue())
                    }
                }
            }
            
            // MARK: * should send values as demand
            it("should send values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .max(10))
                
                pub.tryCompactMap { $0 % 2 == 0 ? $0 : nil }.subscribe(sub)
                
                for i in 0..<100 {
                    pub.send(i)
                }
                
                expect(sub.events.count).to(equal(10))
                for (i, event) in zip(0..<10, sub.events) {
                    switch event {
                    case .value(let output):
                        expect(output).to(equal(i * 2))
                    case .completion(let completion):
                        expect(completion.isFinished).to(beTrue())
                    }
                }
            }
            
            // MARK: * should send a failure if an error is thrown
            it("should send a failure if an error is thrown") {
                let pub = PassthroughSubject<Int, Never>()
                
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryCompactMap {
                    if $0 == 50 {
                        throw CustomError.e1
                    } else {
                        return $0
                    }
                }.subscribe(sub)

                for i in 1..<100 {
                    pub.send(i)
                }
                
                let events = sub.events
                expect(events.count).to(equal(50))
                
                guard let last = events.last else {
                    fail("Events should not be empty")
                    return
                }
                
                switch last {
                case .completion(.failure(let e)):
                    expect(e).to(matchError(CustomError.e1))
                default:
                    fail("Last event should be an error")
                }
            }
        }
        
        
        // MARK: - Release Resources
        describe("release resources") {
            
            // MARK: * should release upstream, downstream and transform closure when cancel
            it("should release upstream, downstream and transform closure when cancel") {
                
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
                expect(downstreamObj).to(beNil())
                expect(closureObj).to(beNil())
            }
            
            // MARK: * should release upstream, downstream and transform closure when finished
            it("should release upstream, downstream and transform closure when finished") {
                
                weak var upstreamObj: PassthroughSubject<Int, Never>?
                weak var downstreamObj: AnyObject?
                weak var closureObj: CustomObject?
                
                var subscription: Subscription?
                
                do {
                    let subject = PassthroughSubject<Int, Never>()
                    upstreamObj = subject
                    
                    let obj = CustomObject()
                    closureObj = obj
                    
                    let pub = subject.map { (v) -> Int in
                        obj.run()
                        return v
                    }
                    
                    let sub = CustomSubscriber<Int, Never>(receiveSubscription: { (s) in
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
                expect(downstreamObj).to(beNil())
                expect(closureObj).to(beNil())
                
                _ = subscription
            }
        }

    }
}
