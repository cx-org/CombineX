import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class AssignSpec: QuickSpec {
    
    override func spec() {
        
        class Object {
            
            var value = 0 {
                didSet {
                    self.records.append(self.value)
                }
            }
            
            var records: [Int] = []
        }
        
        // MARK: - Receive Values
        describe("Receive Values") {
            
            // MARK: 1.1 should receive values that upstream sends
            it("should receive values that upstream sends") {
                let pub = PassthroughSubject<Int, Never>()
                
                let obj = Object()
                let assign = pub.assign(to: \Object.value, on: obj)

                pub.send(1)
                pub.send(2)
                pub.send(3)
                
                expect(obj.records) == [1, 2, 3]
                
                _ = assign
            }
             
            // MARK: 1.2 should not receive values if it haven't received subscription
            it("should not receive values if it hasn't received subscription") {
                let pub = AnyPublisher<Int, Never> { s in
                    _ = s.receive(1)
                    _ = s.receive(2)
                    s.receive(completion: .finished)
                }
                
                let obj = Object()
                let assign = Subscribers.Assign<Object, Int>(object: obj, keyPath: \Object.value)
                
                pub.subscribe(assign)
                
                expect(obj.records) == []
            }
            
            // MARK: 1.3 should not receive values if it has received completion
            it("should not receive values if it has received completion") {
                let pub = AnyPublisher<Int, Never> { s in
                    s.receive(subscription: Subscriptions.empty)
                    _ = s.receive(1)
                    s.receive(completion: .finished)
                    _ = s.receive(2)
                }
                
                let obj = Object()
                let assign = Subscribers.Assign<Object, Int>(object: obj, keyPath: \Object.value)
                
                pub.subscribe(assign)
                
                expect(obj.records) == [1]
            }

            // MARK: 1.4 should not receive vaules when re-activated
            it("should not receive vaules when re-activated") {
                let pub = PassthroughSubject<Int, Never>()

                let obj = Object()
                let assign = Subscribers.Assign<Object, Int>(object: obj, keyPath: \Object.value)
                pub.subscribe(assign)
                pub.send(1)
                pub.send(completion: .finished)

                expect(obj.records) == [1]

                // Try to start a new one
                let pub2 = PassthroughSubject<Int, Never>()
                pub2.subscribe(assign)
                pub2.send(2)
                pub2.send(completion: .finished)

                expect(obj.records) == [1]
            }

            // MARK: 1.5 should not receive vaules if it was cancelled
            it("should not receive vaules if it was cancelled") {
                let pub = PassthroughSubject<Int, Never>()

                let obj = Object()
                let cancellable = pub.assign(to: \Object.value, on: obj)

                cancellable.cancel()
                expect(obj.records) == []
                pub.send(1)
                expect(obj.records) == []
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 should retain subscription and object then release them after completion
            it("should retain subscription and object then release them after completion") {
                weak var object: AnyObject?
                weak var subscription: TracingSubscription?
                let assign: Subscribers.Assign<Object, Int>
                
                do {
                    let obj = Object()
                    assign = .init(object: obj, keyPath: \Object.value)
                    let s = TracingSubscription()
                    assign.receive(subscription: s)
                    object = obj
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                expect(object).toNot(beNil())
                assign.receive(completion: .finished)
                expect(subscription).to(beNil())
                expect(object).to(beNil())
            }
            
            // MARK: 2.2 should retain subscription and object then release them after cancel
            it("should retain subscription and object then release them after cancel") {
                weak var object: AnyObject?
                weak var subscription: TracingSubscription?
                var cancelled = false
                
                let assign: Subscribers.Assign<Object, Int>
                
                do {
                    let obj = Object()
                    object = obj
                    
                    assign = Subscribers.Assign<Object, Int>(object: obj, keyPath: \Object.value)
                    
                    let s = TracingSubscription(receiveCancel: {
                        cancelled = true
                    })
                    assign.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                expect(object).toNot(beNil())
                expect(cancelled) == false
                assign.cancel()
                expect(subscription).to(beNil())
                expect(object).to(beNil())
                expect(cancelled) == true
            }
            
            // MARK: 2.3 should not release root when complete if there is no subscription
            it("should not release root when complete if there is no subscription") {
                let assign: Subscribers.Assign<Object, Int>
                weak var obj: Object?
                do {
                    let o = Object()
                    assign = Subscribers.Assign<Object, Int>(object: o, keyPath: \Object.value)
                    obj = o
                }
                
                expect(obj).toNot(beNil())
                assign.receive(completion: .finished)
                expect(obj).toNot(beNil())
            }
            
            // MARK: 2.4 should not release root when cancel if there is no subscription
            it("should not release root when cancel") {
                let assign: Subscribers.Assign<Object, Int>
                weak var obj: Object?
                do {
                    let o = Object()
                    assign = Subscribers.Assign<Object, Int>(object: o, keyPath: \Object.value)
                    obj = o
                }
                
                expect(obj).toNot(beNil())
                assign.cancel()
                expect(obj).toNot(beNil())
            }
        }
    }
}
