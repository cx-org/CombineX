import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class CombineLatestSpec: QuickSpec {
 
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            fit("test") {
                let pub0 = TestSubject<Int, Never>()
                let pub1 = TestSubject<Int, Never>()
                
                let pub = pub0.combineLatest(pub1)
                
                var counter = 0
                let sub = TestSubscriber<(Int, Int), Never>(receiveSubscription: { (s) in
                    s.request(.max(5))
                }, receiveValue: { v in
                    print("receive", v, counter + 1)
                    defer {
                        counter += 1
                    }
                    return counter == 0 ? .max(20) : .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                100.times {
                    [pub0, pub1].randomElement()!.send($0)
                }
            }
            
            // MARK: 1.1 should combine latest of 2
            it("should combine latest of 2") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.combineLatest(subject1, +)
                let sub = makeTestSubscriber(String.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                subject0.send("0")
                subject0.send("1")
                subject1.send("a")
                
                subject0.send("2")
                subject1.send("b")
                subject1.send("c")
                
                let expected = ["1a", "2a", "2b", "2c"].map { TestEvent<String, TestError>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.2 should combine latest of 3
            it("should combine latest of 3") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                let subject2 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.combineLatest(subject1, subject2, { $0 + $1 + $2 })
                let sub = makeTestSubscriber(String.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                subject0.send("0")
                subject0.send("1")
                subject0.send("2")
                subject1.send("a")
                subject1.send("b")
                subject2.send("A")

                subject0.send("3")
                subject1.send("c")
                subject1.send("d")
                subject2.send("B")
                subject2.send("C")
                subject2.send("D")
                
                let expected = ["2bA", "3bA", "3cA", "3dA", "3dB", "3dC", "3dD"].map { TestEvent<String, TestError>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.3 should send as many as demands
            it("should send as many as demands") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                var counter = 0
                let pub = subject0.combineLatest(subject1, +)
                let sub = TestSubscriber<String, TestError>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    defer { counter += 1}
                    return [0, 10].contains(counter) ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                100.times {
                    [subject0, subject1].randomElement()!.send("\($0)")
                }
                
                expect(sub.events.count).to(equal(12))
            }
        }
    }
}
