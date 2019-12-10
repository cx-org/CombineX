import CombineX
import Foundation

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    
    open class NSObject<Base: Foundation.NSObject>: CXWrapper {
        
        public let base: Base
        
        public required init(wrapping base: Base) {
            self.base = base
        }
    }
}

extension NSObject: CXWrapping {
    
    public typealias CX = CXWrappers.NSObject<NSObject>
}

#if canImport(ObjectiveC)

// FIXME: NSObject.KeyValueObservingPublisher doesn't conform ot `Publisher` protocol, 🤔.
extension NSObject.CX {
    
    func keyValueObservingPublisher<Value>(_ keyPath: KeyPath<Base, Value>, _ options: NSKeyValueObservingOptions) -> KeyValueObservingPublisher<Base, Value> {
        return .init(object: self.base, keyPath: keyPath, options: options)
    }
}

extension NSObject.CX {
    
    /// A publisher that emits events when the value of a KVO-compliant property changes.
    public struct KeyValueObservingPublisher<Subject, Value>: Equatable where Subject: NSObject {

        public let object: Subject

        public let keyPath: KeyPath<Subject, Value>

        public let options: NSKeyValueObservingOptions

        public init(object: Subject, keyPath: KeyPath<Subject, Value>, options: NSKeyValueObservingOptions) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
        }
    }
}

#endif
