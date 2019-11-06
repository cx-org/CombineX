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
    public struct KeyValueObservingPublisher<Subject, Value> : Equatable where Subject : NSObject {

        public let object: Subject

        public let keyPath: KeyPath<Subject, Value>

        public let options: NSKeyValueObservingOptions

        public init(object: Subject, keyPath: KeyPath<Subject, Value>, options: NSKeyValueObservingOptions) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
        }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (lhs: KeyValueObservingPublisher<Subject, Value>, rhs: KeyValueObservingPublisher<Subject, Value>) -> Bool {
            return lhs.object == rhs.object
                && lhs.keyPath == rhs.keyPath
                && lhs.options == rhs.options
        }
    }
}

#endif
