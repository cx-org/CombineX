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

class AssignSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            Resources.release()
        }
        
        class Obj {
            var value = 0 {
                didSet {
                    self.histories.append(self.value)
                }
            }
            
            var histories: [Int] = []
        }
        
        // MARK: - Receive Values
        describe("Receive Values") {
            
            // MARK: 1.1 should receive values that upstream send
            it("should receive values that upstream send") {
                let pub = PassthroughSubject<Int, Never>()
                
                let obj = Obj()
                let assign = pub.assign(to: \Obj.value, on: obj)

                pub.send(1)
                pub.send(2)
                pub.send(3)
                
                expect(obj.histories).to(equal([1, 2, 3]))
                
                _ = assign
            }
            
            // MARK: 1.2 should not receive values after completion
            it("should not receive values after completion") {
                let pub = PassthroughSubject<Int, Never>()
                
                let obj = Obj()
                let assign = pub.assign(to: \Obj.value, on: obj)
                
                pub.send(completion: .finished)
                pub.send(1)
                pub.send(2)
                pub.send(3)
                
                expect(obj.histories).to(equal([]))
                
                _ = assign
            }
            
            // MARK: 1.3 should not receive event after cancel
            it("should not receive event after cancel") {
                let pub = PassthroughSubject<Int, Never>()
                
                let obj = Obj()
                let assign = pub.assign(to: \Obj.value, on: obj)
                
                assign.cancel()
                
                pub.send(1)
                pub.send(2)
                pub.send(3)
                
                expect(obj.histories).to(equal([]))
            }
            
            // MARK: 1.4 should not receive events after complete then re-subscribe
            it("should not receive events after complete then re-subscribe") {
                let pub1 = PassthroughSubject<Int, Never>()
                let obj = Obj()
                let assign = Subscribers.Assign<Obj, Int>(object: obj, keyPath: \Obj.value)
                pub1.subscribe(assign)
                
                pub1.send(completion: .finished)
                
                let pub2 = PassthroughSubject<Int, Never>()
                pub2.subscribe(assign)
                
                pub2.send(1)
                
                expect(obj.histories).to(equal([]))
            }
            
            // MARK: 1.5 should receive events after cancel then re-subscribe
            it("should receive events after cancel then re-subscribe") {
                let obj = Obj()
                let assign = Subscribers.Assign<Obj, Int>(object: obj, keyPath: \Obj.value)
                assign.cancel()
                
                let pub = PassthroughSubject<Int, Never>()
                pub.subscribe(assign)
                
                pub.send(1)
                
                expect(obj.histories).to(equal([1]))
            }
        }
        
        // MARK: - Release Resources
        describe("Release Resources") {
            
            // MARK: 2.1 should retain subscription then release it after completion
            it("should retain subscription then release it after completion") {
                let obj = Obj()
                let assign = Subscribers.Assign<Obj, Int>(object: obj, keyPath: \Obj.value)
                
                weak var subscription: TestSubscription?
                
                do {
                    let s = TestSubscription(request: { (demand) in
                    }, cancel: {
                    })
                    
                    assign.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                assign.receive(completion: .finished)
                expect(subscription).to(beNil())
            }
            
            // MARK: 2.2 should retain subscription then release it after cancel
            it("should retain subscription then release it after cancel") {
                let obj = Obj()
                let assign = Subscribers.Assign<Obj, Int>(object: obj, keyPath: \Obj.value)
                
                weak var subscription: TestSubscription?
                
                do {
                    let s = TestSubscription(request: { (demand) in
                    }, cancel: {
                    })
                    
                    assign.receive(subscription: s)
                    subscription = s
                }
                
                expect(subscription).toNot(beNil())
                assign.cancel()
                expect(subscription).to(beNil())
            }
            
            // MARK: 2.3 should release root when complete
            it("should release root when complete") {
                let subject = PassthroughSubject<Int, Never>()
                
                var cancel: AnyCancellable?
                weak var obj: Obj?
                do {
                    let o = Obj()
                    cancel = subject.assign(to: \Obj.value, on: o)
                    obj = o
                }
                
                expect(obj).toNot(beNil())
                subject.send(completion: .finished)
                expect(obj).to(beNil())
                
                _ = cancel
            }
            
            // MARK: 2.4 should not release root when cancel
            it("should not release root when cancel") {
                var assign: Subscribers.Assign<Obj, Int>?
                weak var obj: Obj?
                do {
                    let o = Obj()
                    assign = Subscribers.Assign<Obj, Int>(object: o, keyPath: \Obj.value)
                    obj = o
                }
                
                expect(obj).toNot(beNil())
                assign?.cancel()
                expect(obj).toNot(beNil())
            }
        }
    }
}
