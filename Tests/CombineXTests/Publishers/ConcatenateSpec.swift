import CXShim
import CXTestUtility
import Nimble
import Quick

class ConcatenateSpec: QuickSpec {
    
    override func spec() {
        
        // MARK: - Send Values
        describe("Send Values") {
            
            // MARK: 1.1 should concatenate two publishers
            it("should concatenate two publishers") {
                let p0 = Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4])
                let p1 = Just(5)
                
                let pub = Publishers.Concatenate(prefix: p0, suffix: p1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                let valueEvents = (1...5).map(TracingSubscriber<Int, Never>.Event.value)
                let expected = valueEvents + [.completion(.finished)]
                expect(sub.eventsWithoutSubscription) == expected
            }
            
            // MARK: 1.2 should send as many value as demand
            it("should send as many value as demand") {
                let p0 = Publishers.Sequence<[Int], Never>(sequence: Array(0..<10))
                let p1 = Publishers.Sequence<[Int], Never>(sequence: Array(10..<20))
                
                let pub = Publishers.Concatenate(prefix: p0, suffix: p1)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .max(10)) { v in
                    [0, 10].contains(v) ? .max(1) : .none
                }
                
                let events = (0..<12).map(TracingSubscriber<Int, Never>.Event.value)
                expect(sub.eventsWithoutSubscription) == events
            }
            
            // MARK: 1.3 should subscribe suffix after the finish of prefix
            it("should subscribe suffix after the finish of prefix") {
                enum Event {
                    case subscribeToPrefix
                    case beforePrefixFinish
                    case afterPrefixFinish
                    case subscribeToSuffix
                }
                var events: [Event] = []
                
                let pub1 = AnyPublisher<Int, Never> { s in
                    events.append(.subscribeToPrefix)
                    s.receive(subscription: Subscriptions.empty)
                    events.append(.beforePrefixFinish)
                    s.receive(completion: .finished)
                    events.append(.afterPrefixFinish)
                }
                let pub2 = AnyPublisher<Int, Never> { s in
                    events.append(.subscribeToSuffix)
                    s.receive(subscription: Subscriptions.empty)
                }
                
                let pub = pub1.append(pub2)
                let sub = pub.subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(events) == [
                    .subscribeToPrefix,
                    .beforePrefixFinish,
                    .subscribeToSuffix,
                    .afterPrefixFinish
                ]
                
                withExtendedLifetime(sub) {}
            }
        }
    }
}
