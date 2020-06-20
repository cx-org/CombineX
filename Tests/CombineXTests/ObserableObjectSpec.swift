import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class ObserableObjectSpec: QuickSpec {

    #if swift(>=5.1)
    
    override func spec() {
        
        // MARK: - Publish
        describe("Publish") {
            
            // MARK: 1.1 should publish observed value's change
            it("should publish observed value's change") {
                let obj = ObservableDerived()
                let sub = obj
                    .objectWillChange
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                obj.x = 1
                obj.y = "foo"
                expect(sub.eventsWithoutSubscription.count) == 0
                
                obj.a = 1
                expect(sub.eventsWithoutSubscription.count) == 1
                
                obj.a = 2
                expect(sub.eventsWithoutSubscription.count) == 2
                
                obj.a += 1
                expect(sub.eventsWithoutSubscription.count) == 3
                
                obj.d.toggle()
                expect(sub.eventsWithoutSubscription.count) == 4
                
                obj.e.append(1)
                expect(sub.eventsWithoutSubscription.count) == 5
            }
            
            // MARK: 1.2 generic class should publish observed value's change
            it("generic class should publish observed value's change") {
                let obj = ObservableGeneric(0, 0.0)
                let sub = obj
                    .objectWillChange
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription.count) == 0
                
                obj.a = 1
                expect(sub.eventsWithoutSubscription.count) == 1
                
                obj.b = 1.0
                expect(sub.eventsWithoutSubscription.count) == 2
            }
            
            // MARK: 1.3 derived class should publish non-observable base class's change
            it("derived class should publish non-observable base class's change") {
                let obj = ObservableDerivedWithNonObservableBase()
                let sub = obj
                    .objectWillChange
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription.count) == 0
                
                obj.a += 1
                expect(sub.eventsWithoutSubscription.count) == 1
                
                obj.b += 1
                expect(sub.eventsWithoutSubscription.count) == 2
                
                obj.c += 1
                expect(sub.eventsWithoutSubscription.count) == 3
                
                obj.d += 1
                expect(sub.eventsWithoutSubscription.count) == 4
            }
            
            // MARK: class derived from objc should publish observed value's change
            it("class derived from objc should publish observed value's change") {
                let obj = ObservableDerivedObjc()
                let sub = obj
                    .objectWillChange
                    .subscribeTracingSubscriber(initialDemand: .unlimited)
                
                expect(sub.eventsWithoutSubscription.count) == 0
                
                obj.a += 1
                expect(sub.eventsWithoutSubscription.count) == 1
                
                obj.b += 1
                expect(sub.eventsWithoutSubscription.count) == 2
            }
        }
        
        // MARK: - Lifetime
        describe("Lifetime") {
            
            // MARK: 2.1 instance of specific kind of class should return a new objectWillChange every time
            // Versioning: see VersioningObserableObjectSpec
            
            // MARK: 2.2 other type should return the same objectWillChange every time
            it("other type should return the same objectWillChange every time") {
                var objects: [ObservableObjectDefaultImplementation] = [
                    PublishedFieldIsConstant(),
                    ObservableBase(),
                    ObservableDerived(),
                    ObservableDerivedObjc(),
                    ObservableGeneric(0, 0.0),
                    ObservableDerivedWithNonObservableBase(),
                ]
                
                // no resilient classes on non-Darwin platforms
                #if !canImport(Darwin)
                objects += [
                    ObservableDerivedResilient(), // subclass of resilient class
                    ObservableDerivedGenericResilient(0, 0.0), // generic subclass of resilient class
                ]
                #endif
                
                for obj in objects {
                    let pub1 = obj.objectWillChange
                    let pub2 = obj.objectWillChange
                    expect(pub1).to(beIdenticalTo(pub2), description: "instance of \(type(of: obj)) should return the same objectWillChange every time")
                }
            }
        }
    }

    #endif
}

#if swift(>=5.1)

private protocol ObservableObjectDefaultImplementation {
    var objectWillChange: ObservableObjectPublisher { get }
}
private typealias DefaultImplementedObservableObject = ObservableObject & ObservableObjectDefaultImplementation

private class ObservableBase: DefaultImplementedObservableObject {
    @Published var a = 0
    var b = Published(initialValue: 0.0)
    let c = Published(initialValue: "")
    var x = 0
    var y = ""
}

private final class ObservableDerived: ObservableBase {
    @Published var d = false
    @Published var e = [Int]()
}

private class ObservableGeneric<A, B>: DefaultImplementedObservableObject {
    @Published var a: A
    @Published var b: B
    init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
}

private class NonObservableBase {
    @Published var a = 0
    @Published var b = 0
}

private final class ObservableDerivedWithNonObservableBase: NonObservableBase, DefaultImplementedObservableObject {
    @Published var c = 0
    @Published var d = 0
}

private final class ObservableDerivedObjc: NSDate, DefaultImplementedObservableObject {
    @Published var a = 0
    @Published var b = 0
}

// MARK: -

private final class NoFields: DefaultImplementedObservableObject {}

private final class NoPublishedFields: DefaultImplementedObservableObject {
    var x = 0
    var y = ""
}

private final class PublishedFieldIsConstant: DefaultImplementedObservableObject {
    let a = Published(initialValue: 0)
}

extension NSUUID: DefaultImplementedObservableObject {}

extension JSONEncoder: DefaultImplementedObservableObject {}

private final class ObservableDerivedResilient: JSONDecoder, DefaultImplementedObservableObject {
    @Published var a = 0
    @Published var b = 0.0
}

private final class ObservableDerivedGenericResilient<A, B>: JSONDecoder, DefaultImplementedObservableObject {
    @Published var a: A
    @Published var b: B

    init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
}

#endif
