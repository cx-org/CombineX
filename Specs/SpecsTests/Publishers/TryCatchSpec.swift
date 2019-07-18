import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class TryCatchSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should use new publisher if upstream ends with error
            it("should use new publisher if upstream ends with error") {
                let p0 = Fail<Int, CustomError>(error: .e0)
                let p1 = Publishers.Sequence<[Int], CustomError>(sequence: [1, 2, 3])
                
                let pub = p0.tryCatch({ _ in p1 })
                let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let events = [1, 2, 3].map { CustomSubscriber<Int, Error>.Event.value($0) }
                let expected = events + [.completion(.finished)]
                expect(sub.events.count).to(equal(expected.count))
                for (e0, e1) in zip(sub.events, expected) {
                    switch (e0, e1) {
                    case (.value(let a), .value(let b)):
                        expect(a).to(equal(b))
                    case (.completion, .completion):
                        expect(e0.isFinished()).to(beTrue())
                    default:
                        fail()
                    }
                }
            }
            
            // MARK: 1.2 should send as many value as demand
            it("should send as many value as demand") {
                let p0 = Publishers.Sequence<[Int], CustomError>(sequence: [1, 2, 3, 4, 5]).append(Fail<Int, CustomError>(error: .e0))
                
                let p1 = Publishers.Sequence<[Int], CustomError>(sequence: [6, 7, 8, 9, 10])
                
                let pub = p0.tryCatch { _ in p1 }
                let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                    s.request(.max(7))
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let events = Array(1...7).map { CustomSubscriber<Int, Never>.Event.value($0) }
                expect(sub.events.count).to(equal(events.count))
                for (e0, e1) in zip(sub.events, events) {
                    switch (e0, e1) {
                    case (.value(let a), .value(let b)):
                        expect(a).to(equal(b))
                    default:
                        fail()
                    }
                }
            }
            
            // MARK: 1.3 should fail if error handle throws an error
            it("should fail if error handle throws an error") {
                typealias Pub0 = Fail<Int, CustomError>
                typealias Pub1 = Publishers.Sequence<[Int], CustomError>
                let p0 = Pub0(error: .e0)
                
                let pub: Publishers.TryCatch<Pub0, Pub1> = p0.tryCatch { _ in throw CustomError.e2 }
                let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                expect(sub.events.count).to(equal(1))
                expect(sub.events.last?.error).to(matchError(CustomError.e2))
            }
        }
    }
}
