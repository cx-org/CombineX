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
            
            it("should replay its events") {
                var recoding = Record<Int, TestError>.Recording()
                recoding.receive(1)
                print(recoding, recoding.output, recoding.completion)
                
                recoding.receive(completion: .failure(.e0))
                print(recoding, recoding.output, recoding.completion)
//                recoding.receive(completion: .failure(.e1))
                
                recoding = .init(output: [1], completion: .finished)
                print(recoding, recoding.output, recoding.completion)
            }
        }
    }
}
