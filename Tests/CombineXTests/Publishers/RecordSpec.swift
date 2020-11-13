import CXShim
import CXTestUtility
import Nimble
import Quick

class RecordSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Recording
        describe("Recording") {
            
            typealias Recording = Record<Int, TestError>.Recording
            
            // MARK: 1.1 should record events
            it("should record events") {
                var recording = Recording()
                
                recording.receive(1)
                recording.receive(2)
                recording.receive(completion: .failure(.e2))
                
                expect(recording.output) == [1, 2]
                expect(recording.completion) == .failure(.e2)
            }
            
            // MARK: 1.2 should use finish temporarily
            it("should use finish temporarily") {
                let recording = Recording()
                expect(recording.completion) == .finished
            }
            
            #if arch(x86_64) && canImport(Darwin)
            // MARK: 1.3 should fatal if receiving value after receiving completion
            it("should fatal if receiving value after receiving completion") {
                expect {
                    var recording = Recording()
                    recording.receive(completion: .finished)
                    recording.receive(1)
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should fatal if receiving completion after receiving completion
            it("should fatal if receiving completion after receiving completion") {
                expect {
                    var recording = Recording()
                    recording.receive(completion: .finished)
                    recording.receive(completion: .finished)
                }.to(throwAssertion())
            }
            #endif
        }
        
        // MARK: - Replay
        describe("Replay") {
            
            // MARK: 2.1 should replay its events
            it("should replay its events") {
                let record = Record<Int, TestError> {
                    $0.receive(1)
                    $0.receive(2)
                    $0.receive(completion: .failure(.e2))
                }
                
                let sub = record.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription) == [.value(1), .value(2), .completion(.failure(.e2))]
            }
        }
    }
}
