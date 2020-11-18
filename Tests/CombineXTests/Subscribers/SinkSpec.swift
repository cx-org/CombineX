import CXShim
import CXTestUtility
import Nimble
import Quick

class SinkSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Receive Values
        describe("Receive Values") {
            
            // MARK: 1.1 should receive values that upstream send
            it("should receive values that upstream send") {
                let pub = PassthroughSubject<Int, Never>()
                
                var values: [Int] = []
                var completions: [Subscribers.Completion<Never>] = []
                
                let sink = pub.sink(receiveCompletion: { c in
                    completions.append(c)
                }, receiveValue: { v in
                    values.append(v)
                })
                
                pub.send(1)
                pub.send(2)
                pub.send(3)
                pub.send(completion: .finished)
                
                expect(values) == [1, 2, 3]
                expect(completions) == [.finished]
                
                _ = sink
            }
            
            // MARK: 1.2 should receive values whether received subscription or not
            it("should receive values whether received subscription or not") {
                let pub = AnyPublisher<Int, Never> { s in
                    _ = s.receive(1)
                    _ = s.receive(2)
                    s.receive(completion: .finished)
                }
                
                var events: [TracingSubscriber<Int, Never>.Event] = []
                let sink = pub.sink(receiveCompletion: { c in
                    events.append(.completion(c))
                }, receiveValue: { v in
                    events.append(.value(v))
                })
                
                expect(events) == [.value(1), .value(2), .completion(.finished)]
                
                _ = sink
            }

            // MARK: 1.4 should not receive vaules when re-activated
            it("should not receive vaules when re-activated") {
                let pub = PassthroughSubject<Int, Never>()

                var events = [TracingSubscriber<Int, Never>.Event]()
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { c in
                    events.append(.completion(c))
                }, receiveValue: { v in
                    events.append(.value(v))
                })
                pub.subscribe(sink)
                pub.send(1)
                pub.send(completion: .finished)

                expect(events) == [.value(1), .completion(.finished)]

                // Try to start a new one
                let pub2 = PassthroughSubject<Int, Never>()
                pub2.subscribe(sink)
                pub2.send(2)
                pub2.send(completion: .finished)

                expect(events) == [.value(1), .completion(.finished)]
            }

            // MARK: 1.5 should not receive vaules if it was cancelled
            it("should not receive vaules if it was cancelled") {
                let pub = PassthroughSubject<Int, Never>()
                var received = false

                let cancellable = pub.sink { _ in received = true }

                cancellable.cancel()
                expect(received) == false
                pub.send(1)
                expect(received) == false
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 should retain subscription then release it after completion
            it("should retain subscription then release it after completion") {
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { _ in
                }, receiveValue: { _ in
                })
                
                weak var subscription: TracingSubscription?
                var cancelled = false
                
                do {
                    let s = TracingSubscription(receiveCancel: {
                        cancelled = true
                    })
                    sink.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                expect(cancelled) == false
                sink.receive(completion: .finished)
                expect(subscription).to(beNil())
                expect(cancelled) == false
            }
            
            // MARK: 2.2 should retain subscription then release and cancel it after cancel
            it("should retain subscription then release and cancel it after cancel") {
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { _ in
                }, receiveValue: { _ in
                })
                
                weak var subscription: TracingSubscription?
                var cancelled = false
                
                do {
                    let s = TracingSubscription(receiveCancel: {
                        cancelled = true
                    })
                    sink.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                expect(cancelled) == false
                sink.cancel()
                expect(subscription).to(beNil())
                expect(cancelled) == true
            }
            
            // MARK: 2.3 should not retain subscription if it is already subscribing
            it("should not retain subscription if it is already subscribing") {
                let sink = Subscribers.Sink<Int, Never>(receiveCompletion: { _ in
                }, receiveValue: { _ in
                })
                
                sink.receive(subscription: Subscriptions.empty)
                
                weak var subscription: TracingSubscription?
                var cancelled = false
                
                do {
                    let s = TracingSubscription(receiveCancel: {
                        cancelled = true
                    })
                    sink.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).to(beNil())
                expect(cancelled) == true
            }
        }
    }
}
