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

class FutureSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Future
        describe("Future") {
            
            // MARK: 1.1 should send value and finish when promise succeed
            it("should send value and finish when promise succeed") {
                let f = Future<Int, CustomError> { (p) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        p(.success(1))
                    }
                }
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                f.subscribe(sub)
                
                expect(sub.events).to(equal([]))
                expect(sub.events).toEventually(equal([.value(1), .completion(.finished)]))
            }
            
            // MARK: 1.2 should send failure when promise fail
            it("should send failure when promise fail") {
                let f = Future<Int, CustomError> { (p) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        p(.failure(.e0))
                    }
                }
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                f.subscribe(sub)
                
                expect(sub.events).to(equal([]))
                expect(sub.events).toEventually(equal([.completion(.failure(.e0))]))
            }
            
            // MAKR: 1.3 should send events immediately if promise is completed
            it("should send events immediately if promise is completed") {
                let f = Future<Int, CustomError> { (p) in
                    p(.success(1))
                }
                
                let sub = makeCustomSubscriber(Int.self, CustomError.self, .unlimited)
                f.subscribe(sub)
                expect(sub.events).to(equal([.value(1), .completion(.finished)]))
            }
        }
        
        // MARK: - Concurrent
        describe("Concurrent") {
            
            // MARK: should send events to all subscribers even if they subscribe concurrently
            xit("should send events to all subscribers even if they subscribe concurrently") {
                let f = Future<Int, CustomError> { (p) in
                    DispatchQueue.main.async {
                        p(.failure(.e0))
                    }
                }
                let subs = Array.make(count: 100, make: CustomSubscriber<Int, CustomError>(receiveSubscription: { (s) in
                    print("receive subscription", s)
                    s.request(.unlimited)
                }, receiveValue: { v in
                    print("receive value", v)
                    return .none
                }, receiveCompletion: { c in
                    if c == .finished {
                        print("😄 receive completion", c)
                    }
                }))
                
                var holder: Atom<[Any]> = Atom(val: [])
                100.times { i in
                    DispatchQueue.global().async {
                        f.subscribe(subs[i])
//                        let sink = f.sink(receiveCompletion: { (c) in
//                            if c == .finished {
//                                print("👌 receive completion", c)
//                            }
//                        }, receiveValue: { v in
//                        })
//                        holder.withLockMutating { $0.append(sink) }
                    }
                }
                
                waitUntil { (done) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        for sub in subs {
//                            if sub.events == [.completion(.failure(.e0))] {
//
//                            } else {
//                                print("😈", sub.events)
//                            }
//                            expect(sub.events).to(equal([.completion(.failure(.e0))]))
//                        }
                        done()
                    }
                }
            }
        }
    }
}
