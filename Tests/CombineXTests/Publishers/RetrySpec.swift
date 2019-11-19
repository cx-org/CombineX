import CXShim
import CXTestUtility
import Nimble
import Quick

class RetrySpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: - Retry
        describe("Retry") {
            
            // MARK: 1.1 should retry specified times then finish
            it("should retry specified times then finish") {
                var errs: [TestError] = [.e0, .e1, .e2]
                let pub = TestPublisher<Int, TestError> { s in
                    s.receive(subscription: Subscriptions.empty)
                    if errs.isEmpty {
                        s.receive(completion: .finished)
                    } else {
                        s.receive(completion: .failure(errs.removeFirst()))
                    }
                }
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.retry(5).subscribe(sub)
                
                expect(sub.events) == [.completion(.finished)]
            }
            
            // MARK: 1.2 should retry specified times then fail
            it("should retry specified times then fail") {
                var errs: [TestError] = [.e0, .e1, .e2]
                let pub = TestPublisher<Int, TestError> { s in
                    s.receive(subscription: Subscriptions.empty)
                    if errs.isEmpty {
                        s.receive(completion: .finished)
                    } else {
                        s.receive(completion: .failure(errs.removeFirst()))
                    }
                }
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                pub.retry(1).subscribe(sub)
                
                expect(sub.events) == [.completion(.failure(.e1]))
            }
        }
        
        // MARK: - Demand
        describe("Demand") {
            
            // MARK: 2.1 should continue demand after retry
            it("should continue demand after retry") {
                let pub0 = Publishers.Sequence<[Int], TestError>(sequence: [1, 2, 3])
                let pub1 = Fail<Int, TestError>(error: .e0)
                let pub = pub0.append(pub1)

                let sub = makeTestSubscriber(Int.self, TestError.self, .max(5))
                pub.retry(1).subscribe(sub)
                
                expect(sub.events) == [.value(1), .value(2), .value(3), .value(1), .value(2)]
            }
        }
    }
}
 
