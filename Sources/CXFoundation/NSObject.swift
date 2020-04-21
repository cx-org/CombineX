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
