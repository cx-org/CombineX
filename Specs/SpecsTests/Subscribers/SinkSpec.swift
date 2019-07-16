import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class SinkSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Receive Values
        describe("Receive Values") {
            
            // MARK: 1.1 should receive values that upstream send
            it("should receive values that upstream send") {
                let pub = PassthroughSubject<Int, Never>()
                
                var values: [Int] = []
                var completions: [Subscribers.Completion<Never>] = []
                
                let sink = pub.sink(receiveCompletion: { (c) in
                    completions.append(c)
                }, receiveValue: { v in
                    values.append(v)
                })
                
                pub.send(1)
                pub.send(2)
                pub.send(3)
                pub.send(completion: .finished)
                
                expect(values).to(equal([1, 2, 3]))
                expect(completions).to(equal([.finished]))
                
                _ = sink
            }
            
            // MARK: 1.2 should not receive values after completion
            it("should not receive values after completion") {
                let pub = PassthroughSubject<Int, Never>()
                
                var values: [Int] = []
                var completions: [Subscribers.Completion<Never>] = []
                
                let sink = pub.sink(receiveCompletion: { (c) in
                    completions.append(c)
                }, receiveValue: { v in
                    values.append(v)
                })
                
                pub.send(completion: .finished)
                pub.send(1)
                pub.send(2)
                pub.send(3)
                
                expect(values).to(equal([]))
                expect(completions).to(equal([.finished]))
                
                _ = sink
            }
            
            
            // MARK: 1.3 should not receive event after cancel
            it("should not receive event after cancel") {
                let pub = PassthroughSubject<Int, Never>()
                
                var values: [Int] = []
                var completions: [Subscribers.Completion<Never>] = []
                
                let sink = pub.sink(receiveCompletion: { (c) in
                    completions.append(c)
                }, receiveValue: { v in
                    values.append(v)
                })
                
                sink.cancel()
                
                pub.send(1)
                pub.send(2)
                pub.send(3)
                pub.send(completion: .finished)
                
                expect(values).to(equal([]))
                expect(completions).to(equal([]))
            }
            
            // MARK: 1.4 should receive events after complete then re-subscribe
            it("should receive events after complete then re-subscribe") {
                let pub1 = PassthroughSubject<Int, Never>()
                
                var values: [Int] = []
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { (c) in
                }, receiveValue: { v in
                    values.append(v)
                })
                pub1.subscribe(sink)
                
                pub1.send(completion: .finished)
                
                let pub = PassthroughSubject<Int, Never>()
                pub.subscribe(sink)
                
                pub.send(1)
                
                expect(values).to(equal([1]))
            }
            
            // MARK: 1.5 should receive events after cancel then re-subscribe
            it("should receive events after cancel then re-subscribe") {
                var values: [Int] = []
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { (c) in
                }, receiveValue: { v in
                    values.append(v)
                })
                sink.cancel()
                
                let pub = PassthroughSubject<Int, Never>()
                pub.subscribe(sink)
                
                pub.send(1)
                
                expect(values).to(equal([1]))
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 should retain subscription then release it after completion
            it("should retain subscription then release it after completion") {
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { c in
                }, receiveValue: { v in
                })
                
                weak var subscription: CustomSubscription?
                
                do {
                    let s = CustomSubscription(request: { (demand) in
                    }, cancel: {
                    })
                    
                    sink.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                sink.receive(completion: .finished)
                expect(subscription).to(beNil())
            }
            
            // MARK: 2.2 should retain subscription then release it after cancel
            it("should retain subscription then release it after cancel") {
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { c in
                }, receiveValue: { v in
                })
                
                weak var subscription: CustomSubscription?
                
                do {
                    let s = CustomSubscription(request: { (demand) in
                    }, cancel: {
                    })
                    
                    sink.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                sink.cancel()
                expect(subscription).to(beNil())
            }
        }
    }
}
