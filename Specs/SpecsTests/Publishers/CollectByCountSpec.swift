import Quick
import Nimble

#if USE_COMBINE
import Combine
#else
import CombineX
#endif

class CollectByCountSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should relay values by collection
            it("should relay values by collection") {
                let pub = PassthroughSubject<Int, CustomError>()
                let sub = CustomSubscriber<[Int], CustomError>(receiveSubscription: { (s) in
                    s.request(.unlimited)
                }, receiveValue: { v in
                    return .none
                }, receiveCompletion: { c in
                })
                
                pub.collect(2).subscribe(sub)
                
                5.times {
                    pub.send($0)
                }
                pub.send(completion: .finished)
                
                expect(sub.events).to(equal(
                    [.value([0, 1]), .value([2, 3]), .value([4]), .completion(.finished)]
                ))
            }
            
            // MARK: 1.2 should relay as many values as demand
            it("should relay as many values as demand") {
                let pub = PassthroughSubject<Int, CustomError>()
                let sub = CustomSubscriber<[Int], CustomError>(receiveSubscription: { (s) in
                    s.request(.max(1))
                }, receiveValue: { v in
                    return v == [0, 1] ? .max(1) : .none
                }, receiveCompletion: { c in
                })
                
                pub.collect(2).subscribe(sub)
                
                5.times {
                    pub.send($0)
                }
                pub.send(completion: .finished)
                
                expect(sub.events).to(equal(
                    [.value([0, 1]), .value([2, 3]), .completion(.finished)]
                ))
            }
        }
    }
}
