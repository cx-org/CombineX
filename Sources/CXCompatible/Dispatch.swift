#if canImport(Dispatch)

import Dispatch

#if !COCOAPODS
import CXNamespace
#endif

extension CXWrappers {
    public typealias DispatchQueue = Dispatch.DispatchQueue
}

#endif
