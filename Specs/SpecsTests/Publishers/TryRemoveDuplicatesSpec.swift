import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class TryRemoveDuplicatesSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should remove duplicate values from upstream
            it("should remove duplicate values from upstream") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryRemoveDuplicates(by: ==)
                    .subscribe(sub)
                
                pub.send(1)
                pub.send(1)
                pub.send(2)
                pub.send(2)
                pub.send(3)
                pub.send(3)
                
                let got = sub.events.mapError { $0 as! CustomError }
                
                expect(got).to(equal([.value(1), .value(2), .value(3)]))
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Error.self, .max(10))
                pub.tryRemoveDuplicates(by: ==).subscribe(sub)
                
                for _ in 0..<100 {
                    pub.send(Int.random(in: 0..<100))
                }
                
                expect(sub.events.count).to(equal(10))
            }
            
            // MARK: 1.3 should fail if closure throws error
            it("should fail if closure throws error") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeCustomSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryRemoveDuplicates(by: { (_, _) -> Bool in
                    throw CustomError.e0
                }).subscribe(sub)
                
                pub.send(1)
                pub.send(1)
                
                let got = sub.events.mapError { $0 as! CustomError }
                
                expect(got).to(equal([.value(1), .completion(.failure(.e0))]))
            }
        }
    }
}
