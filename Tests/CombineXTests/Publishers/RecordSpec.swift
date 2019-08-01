import Quick
import Nimble

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

class RecordSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            Resources.release()
        }
        
        // MARK: - Recording
        describe("Recording") {
            
            typealias Recording = Record<Int, TestError>.Recording
            
            // MARK: 1.1 should record events
            it("should record events") {
                var recording = Recording()
                
                recording.receive(1)
                recording.receive(2)
                recording.receive(completion: .failure(.e2))
                
                expect(recording.output).to(equal([1, 2]))
                expect(recording.completion).to(equal(.failure(.e2)))
            }
            
            // MARK: 1.2 should use finish temporarily
            it("should use finish temporarily") {
                let recording = Recording()
                expect(recording.completion).to(equal(.finished))
            }
            
            #if !SWIFT_PACKAGE
            // MARK: 1.3 should fatal if receiving value after receiving completion
            xit("should fatal if receiving value after receiving completion") {
                var recording = Recording()
                expect {
                    recording.receive(completion: .finished)
                    recording.receive(1)
                    return nil
                }.to(throwAssertion())
            }
            
            // MARK: 1.4 should fatal if receiving completion after receiving completion
            xit("should fatal if receiving completion after receiving completion") {
                var recording = Recording()
                expect {
                    recording.receive(completion: .finished)
                    recording.receive(completion: .finished)
                    return nil
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
                
                let sub = makeTestSubscriber(Int.self, TestError.self, .unlimited)
                record.subscribe(sub)
                
                expect(sub.events).to(equal([.value(1), .value(2), .completion(.failure(.e2))]))
            }
        }
    }
}
