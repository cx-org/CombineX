import Quick
import Nimble
@testable import CXFoundation
import Foundation
import CombineX

class URLSessionSpec: QuickSpec {
    
    let URL = Foundation.URL(string: "https://github.com/repos/cx-org/CXFoundation/releases/latest")!
    
    override func spec() {
        
        // MARK: 1.1 should receive response from session
        it("should receive response from session") {
            var response: URLResponse?
            let pub = URLSession.shared.cx.dataTaskPublisher(for: self.URL)
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
