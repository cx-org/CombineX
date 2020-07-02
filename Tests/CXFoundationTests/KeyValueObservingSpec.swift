import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class KeyValueObservingSpec: QuickSpec {
    #if swift(>=5.1) && canImport(ObjectiveC)

    override func spec() {

        // Note that our implementation of the KVO publisher is a copy of Apple's open source code, so its behavior should be absolutely identical.

        // MARK: - Publish
        describe("Publish") {
            // MARK: 1.1 should publish on assignments
            it("should publish on assignments") {
                let x = X()
                let sub = x.cx
                    .publisher(for: \.p, options: [])
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                expect(sub.eventsWithoutSubscription) == []
                x.p = 1
                x.p = 2
                expect(sub.eventsWithoutSubscription) == [.value(1), .value(2)]
            }

            // MARK: 1.2 should publish immediately if .initial
            it("should publish immediately if .initial") {
                let x = X()
                let sub = x.cx
                    .publisher(for: \.p, options: [.initial])
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                expect(sub.eventsWithoutSubscription) == [.value(0)]
            }


            // MARK: 1.2 should publish before also if .prior
            it("should publish before also if .prior") {
                let x = X()
                let sub = x.cx
                    .publisher(for: \.p, options: [.prior])
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                expect(sub.eventsWithoutSubscription) == []
                x.p = 1
                x.p = 2
                expect(sub.eventsWithoutSubscription) == [.value(0), .value(1), .value(1), .value(2)]
            }

            // MARK: 1.3 should publish immediately and before also if .initial and .prior
            it("should publish immediately and before also if .initial and .prior") {
                let x = X()
                let sub = x.cx
                    .publisher(for: \.p, options: [.initial, .prior])
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                expect(sub.eventsWithoutSubscription) == [.value(0)]
                x.p = 1
                x.p = 2
                expect(sub.eventsWithoutSubscription) == [.value(0), .value(0), .value(1), .value(1), .value(2)]
            }
        }

        // MARK: - Demand
        describe("Demand") {
            // MARK: 2.1 should only send values when demand is not zero
            it("should only send values when demand is not zero") {
                let x = X()
                // With .initial, the publisher caches the property value at subscription time until it receives its first non-zero demand.
                let sub = x.cx
                    .publisher(for: \.p, options: [.initial])
                    .subscribeTracingSubscriber(initialDemand: nil)

                expect(sub.eventsWithoutSubscription) == []
                x.p = 1
                x.p = 2
                expect(sub.eventsWithoutSubscription) == []
                sub.subscription!.request(.max(1))
                // x.p was 0 when I subscribed.
                expect(sub.eventsWithoutSubscription) == [.value(0)]
                x.p = 3
                x.p = 4
                sub.subscription!.request(.max(3))
                x.p = 5
                x.p = 6
                x.p = 7
                x.p = 8

                // This is the "correct" expectation:
                //
                //     expect(sub.eventsWithoutSubscription) == [.value(0), .value(5), .value(6), .value(7)]
                //
                // But Apple's implementation is buggy! It always decrements the value given to `request(_:)` by 1. If you request 1, you get nothing. If you request 2, you get 1. And so on.
                // I did not fix that bug when I adapted Apple's implementation for CombineX, so we exhibit the same bug. Here's the expectation that matches the buggy behavior:
                expect(sub.eventsWithoutSubscription) == [.value(0), .value(5), .value(6)]
            }
        }

        // MARK: - Subclasses
        describe("Subclasses") {
            // MARK: 3.1 should support the KVO publisher and their own customizations
            it("should support the KVO publisher and their own customizations") {
                // This method won't compile if .cx doesn't produce something that supports both the KVO publisher and the type-specification customizations. It doesn't have to actually test anything at runtime.

                _ = NotificationCenter.default.cx.publisher(for: \.self, options: [])
                _ = NotificationCenter.default.cx.publisher(for: Notification.Name("x"), object: nil)

                _ = OperationQueue.main.cx.publisher(for: \.isSuspended, options: [])
                OperationQueue.main.cx.schedule { }

                _ = RunLoop.main.cx.publisher(for: \.self, options: [])
                RunLoop.main.cx.schedule { }

                _ = DispatchQueue.main.cx.publisher(for: \.self, options: [])
                DispatchQueue.main.cx.schedule { }

                _ = URLSession.shared.cx.publisher(for: \.self, options: [])
                _ = URLSession.shared.cx.dataTaskPublisher(for: URL(string: "https://localhost/")!)
            }
        }
    }

    class X: NSObject {
        @objc dynamic var p = 0
    }

    #endif /* swift(>=5.1) && canImport(ObjectiveC) */
}
