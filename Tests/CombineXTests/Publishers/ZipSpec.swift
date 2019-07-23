import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class ZipSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
        
            // MARK: 1.1 should zip of 2
            it("should zip of 2") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.zip(subject1, +)
                let sub = makeTestSubscriber(String.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                subject0.send("0")
                subject0.send("1")
                subject1.send("a")
                
                subject0.send("2")
                subject1.send("b")
                subject1.send("c")
                
                let expected = ["0a", "1b", "2c"].map { TestEvent<String, TestError>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.2 should zip of 3
            it("should zip of 3") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                let subject2 = PassthroughSubject<String, TestError>()
                
                let pub = subject0.zip(subject1, subject2, { $0 + $1 + $2 })
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
                
                let expected = ["0aA", "1bB", "2cC", "3dD"].map { TestEvent<String, TestError>.value($0) }
                expect(sub.events).to(equal(expected))
            }
            
            // MARK: 1.3 should finish when one sends a finish
            it("should finish when one sends a finish") {
                let subjects = Array.make(count: 4, make: PassthroughSubject<Int, TestError>())
                let pub = subjects[0].zip(subjects[1], subjects[2], subjects[3]) {
                    $0 + $1 + $2 + $3
                }
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                10.times {
                    subjects[$0 % 4].send($0)
                }
                subjects[3].send(completion: .finished)
                expect(sub.events).to(equal([.value(6), .value(22), .completion(.finished)]))
            }
            
            // MARK: 1.4 should fail when one sends an error
            it("should fail when one sends an error") {
                let subjects = Array.make(count: 4, make: PassthroughSubject<Int, TestError>())
                let pub = subjects[0].zip(subjects[1], subjects[2], subjects[3]) {
                    $0 + $1 + $2 + $3
                }
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.subscribe(sub)
                
                10.times {
                    subjects[$0 % 4].send($0)
                }
                subjects[3].send(completion: .failure(.e0))
                expect(sub.events).to(equal([.value(6), .value(22), .completion(.failure(.e0))]))
            }
            
            // MARK: 1.5 should send as many as demands
            it("should send as many as demands") {
                let subject0 = PassthroughSubject<String, TestError>()
                let subject1 = PassthroughSubject<String, TestError>()
                
                var counter = 0
                let pub = subject0.zip(subject1)
                let sub = TestSubscriber<(String, String), TestError>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    defer {
                        counter += 1
                    }
                    
                    return [0, 10].contains(counter) ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                pub.subscribe(sub)
                
                100.times {
                    subject0.send("\($0)")
                    subject1.send("\($0)")
                }
                
                expect(sub.events.count).to(equal(12))
            }
        }
    }
}
