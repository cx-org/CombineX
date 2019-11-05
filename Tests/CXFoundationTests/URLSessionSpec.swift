import Foundation
import CXShim
import CXTestUtility
import Quick
import Nimble

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let testURL = Foundation.URL(string: "https://github.com/repos/cx-org/CXFoundation/releases/latest")!

class URLSessionSpec: QuickSpec {
    
    override func spec() {
        
        afterEach {
            TestResources.release()
        }
        
        // MARK: 1.1 should receive response from session
        it("should receive response from session") {
            var response: URLResponse?
            let pub = URLSession.shared.cx.dataTaskPublisher(for: testURL)
            let sink = pub
                .sink(receiveCompletion: { (c) in
                }, receiveValue: { v in
                    response = v.response
                })
            
            expect(response).toEventuallyNot(beNil(), timeout: 5)
            _ = sink
        }
    }
}
