import CXShim
import CXTestUtility
import Nimble
import Quick

class VersioningSinkSpec: QuickSpec {
    
    override func spec() {
        
        it("should receive values even if it has received completion") {
            let pub = AnyPublisher<Int, Never> { s in
                _ = s.receive(1)
                s.receive(completion: .finished)
                _ = s.receive(2)
            }
            
            var events: [TracingSubscriber<Int, Never>.Event] = []
            let sink = pub.sink(receiveCompletion: { c in
                events.append(.completion(c))
            }, receiveValue: { v in
                events.append(.value(v))
            })
            
            expect(events).toVersioning([
                .v11_0: equal([.value(1), .completion(.finished), .value(2)]),
                .v12_0: equal([.value(1), .completion(.finished)]),
            ])
            
            _ = sink
        }
    }
}
