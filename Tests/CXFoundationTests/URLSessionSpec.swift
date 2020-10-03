import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let testURL = Foundation.URL(string: "https://github.com/repos/cx-org/CXFoundation/releases/latest")!

class URLSessionSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: 1.1 should receive response from session
        it("should receive response from session") {
            var response: URLResponse?
            let pub = URLSession.shared.cx.dataTaskPublisher(for: testURL)
            let sink = pub
                .sink(receiveCompletion: { _ in
                }, receiveValue: { v in
                    response = v.response
                })
            
            expect(response).toEventuallyNot(beNil(), timeout: .seconds(5))
            _ = sink
        }
    }
}
