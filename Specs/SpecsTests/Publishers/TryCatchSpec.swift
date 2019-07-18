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
                let p1 = Publishers.Sequence<[Int], CustomError>(sequence: [1, 2, 3]).append(Fail(error: .e0))
                
                let pub = p0.tryCatch { _ in p1 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.subscribe(sub)
                
                let got = sub.events.mapError { $0 as! CustomError }
                
                let valueEvents = [1, 2, 3].map { CustomEvent<Int, CustomError>.value($0) }
                let expected = valueEvents + [.completion(.failure(.e0))]
                
                expect(got).to(equal(expected))
            }
            
            // MARK: 1.2 should send as many value as demand
            it("should send as many value as demand") {
                let p0 = Publishers.Sequence<[Int], CustomError>(sequence: Array(0..<10)).append(Fail<Int, CustomError>(error: .e0))
                let p1 = Publishers.Sequence<[Int], CustomError>(sequence: Array(10..<20))
                
                let pub = p0.tryCatch { _ in p1 }
                let sub = CustomSubscriber<Int, Error>(receiveSubscription: { (s) in
                    s.request(.max(10))
                }, receiveValue: { v in
                    [0, 10].contains(v) ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                
                pub.subscribe(sub)
                
                let got = sub.events.mapError { $0 as! CustomError }
                let events = (0..<12).map { CustomEvent<Int, CustomError>.value($0) }
                expect(got).to(equal(events))
            }
            
            // MARK: 1.3 should fail if error handle throws an error
            it("should fail if error handle throws an error") {
                typealias Pub0 = Fail<Int, CustomError>
                typealias Pub1 = Publishers.Sequence<[Int], CustomError>
                let p0 = Pub0(error: .e0)
                
                let pub: Publishers.TryCatch<Pub0, Pub1> = p0.tryCatch { _ in throw CustomError.e2 }
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.subscribe(sub)
                
                let got = sub.events.mapError { $0 as! CustomError }
                expect(got).to(equal([.completion(.failure(.e2))]))
            }
        }
    }
}
