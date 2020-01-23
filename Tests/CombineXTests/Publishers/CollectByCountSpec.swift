import CXShim
import CXTestUtility
import Nimble
import Quick

class CollectByCountSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Relay
        describe("Relay") {
            
            // MARK: 1.1 should relay values by collection
            it("should relay values by collection") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = makeTestSubscriber([Int].self, TestError.self, .unlimited)
                pub.collect(2).subscribe(sub)
                
                5.times {
                    pub.send($0)
                }
                pub.send(completion: .failure(.e0))
                
                expect(sub.events) == [
                    .value([0, 1]),
                    .value([2, 3]),
                    .completion(.failure(.e0))
                ]
            }
            
            // MARK: 1.2 should send unsent values if upstream finishes
            it("should send unsent values if upstream finishes") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = makeTestSubscriber([Int].self, TestError.self, .unlimited)
                pub.collect(2).subscribe(sub)
                
                5.times {
                    pub.send($0)
                }
                pub.send(completion: .finished)
                
                expect(sub.events) == [
                    .value([0, 1]),
                    .value([2, 3]),
                    .value([4]),
                    .completion(.finished)
                ]
            }
            
            // MARK: 1.3 should relay as many values as demand
            it("should relay as many values as demand") {
                let pub = PassthroughSubject<Int, TestError>()
                let sub = TracingSubscriber<[Int], TestError>(receiveSubscription: { s in
                    s.request(.max(1))
                }, receiveValue: { v in
                    v == [0, 1] ? .max(1) : .none
                }, receiveCompletion: { _ in
                })
                
                pub.collect(2).subscribe(sub)
                
                5.times {
                    pub.send($0)
                }
                pub.send(completion: .finished)
                
                expect(sub.events) == [.value([0, 1]), .value([2, 3]), .completion(.finished)]
            }
        }
    }
}
