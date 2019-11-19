import CXShim
import CXTestUtility
import Nimble
import Quick

class TryRemoveDuplicatesSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should remove duplicate values from upstream
            it("should remove duplicate values from upstream") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryRemoveDuplicates(by: ==)
                    .subscribe(sub)
                
                pub.send(1)
                pub.send(1)
                pub.send(2)
                pub.send(2)
                pub.send(3)
                pub.send(3)
                
                let got = sub.events.mapError { $0 as! TestError }
                
                expect(got) == [.value(1), .value(2), .value(3)]
            }
            
            // MARK: 1.2 should send as many values as demand
            it("should send as many values as demand") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .max(10))
                pub.tryRemoveDuplicates(by: ==).subscribe(sub)
                
                for _ in 0..<100 {
                    pub.send(Int.random(in: 0..<100))
                }
                
                expect(sub.events.count) == 10
            }
            
            // MARK: 1.3 should fail if closure throws error
            it("should fail if closure throws error") {
                let pub = PassthroughSubject<Int, Never>()
                let sub = makeTestSubscriber(Int.self, Error.self, .unlimited)
                
                pub.tryRemoveDuplicates(by: { _, _ -> Bool in
                    throw TestError.e0
                }).subscribe(sub)
                
                pub.send(1)
                pub.send(1)
                
                let got = sub.events.mapError { $0 as! TestError }
                
                expect(got) == [.value(1), .completion(.failure(.e0]))
            }
        }
    }
}
