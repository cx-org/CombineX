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

// The naïve conformance of NSObject to CXWrapping looks like this:
//     extension CXWrapping where Self: Foundation.NSObject {
//         public typealias CX = CXWrappers.NSObject<Self>
//     }
//
//     extension NSObject: CXWrapping { }
//
// But that produces a cascade of errors, starting with this:
//
//     .../CombineX/Sources/CXFoundation/JSONDecoder.swift:22:1: error: type 'JSONDecoder' does not conform to protocol 'CXWrapping'
//     extension JSONDecoder: CXWrapping {
//     ^
//     .../CombineX/Sources/CXNamespace/CXNamespace.swift:12:20: note: multiple matching types named 'CX'
//         associatedtype CX
//                        ^
//     .../CombineX/Sources/CXFoundation/JSONDecoder.swift:24:22: note: possibly intended match
//         public typealias CX = CXWrappers.JSONDecoder
//                          ^
//     .../CombineX/Sources/CXFoundation/NSObject.swift:21:22: note: possibly intended match
//         public typealias CX = CXWrappers.NSObject<Self>
//
// I think the root problem might be that JSONDecoder (and several other types) somehow secretly subclass NSObject on Apple platforms, and so it tries to pick up two different definitions of `CX`.
//
// My workaround here is to *not* conform NSObject to CXWrapping at all.
//
// A different fix is to rework CXWrapper/CXWrapping entirely. They are analogous to RxSwift's Reactive/ReactiveCompatible types, and could be implemented the same way RxSwift does (with CXWrapper as a struct rather than a protocol). However, that fix would touch many more files instead of just this one.

public protocol _CXNSObject { }

extension NSObject: _CXNSObject { }

extension _CXNSObject where Self: NSObject {
    public var cx: CXWrappers.NSObject<Self> { .init(wrapping: self) }
}
