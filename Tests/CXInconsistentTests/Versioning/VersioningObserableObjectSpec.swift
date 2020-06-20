import CXShim
import CXTestUtility
import Foundation
import Nimble
import Quick

class VersioningObserableObjectSpec: QuickSpec {
    
    #if swift(>=5.1)

    override func spec() {
        
        // FIXME: Versioning: out of sync
        it("instance of specific kind of class should return the same objectWillChange every time since iOS 13.3") {
            var objects: [ObservableObjectDefaultImplementation] = [
                NoFields(),             // no fields
                NoPublishedFields(),    // no @Published fields
                NSUUID(),               // objc class
                JSONEncoder(),          // resilient class
            ]
            
            // resilient classes on Darwin platforms
            #if canImport(Darwin)
            objects += [
                ObservableDerivedResilient(), // subclass of resilient class
                
                // TODO: combine crash. should move to CXInconsistentTests
                // ObservableDerivedGenericResilient(0, 0.0), // generic subclass of resilient class
            ]
            #endif
            
            for obj in objects {
                let pub1 = obj.objectWillChange
                let pub2 = obj.objectWillChange
                expect(pub1).toVersioning([
                    .v11_0: beNotIdenticalTo(pub2),
                    .v11_3: beIdenticalTo(pub2),
                ])
            }
        }
    }
    
    #endif
}

#if swift(>=5.1)

// TODO: duplicate code of ObserableObjectSpec

private typealias Published = CXShim.Published
private typealias ObservableObject = CXShim.ObservableObject

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
