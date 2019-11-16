#if canImport(Combine)

import Combine
import CombineX
import CXNamespace
import Runtime

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.CombineIdentifier: CXWrapping {
    
    public var cx: CombineX.CombineIdentifier {
        assert(combineCombineIdentifierTypeInfo.properties.count == 1)
        let raw = try! combineCombineIdentifierTypeInfo.properties[0].get(from: self) as! UInt64
        return try! createInstance { _ in
            return UInt(truncatingIfNeeded: raw)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private let combineCombineIdentifierTypeInfo = try! typeInfo(of: Combine.CombineIdentifier.self)

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.CombineIdentifier: ACWrapping {
    
    public var ac: Combine.CombineIdentifier {
        assert(cxCombineIdentifierTypeInfo.properties.count == 1)
        let raw = try! cxCombineIdentifierTypeInfo.properties[0].get(from: self) as! UInt
        return try! createInstance { _ in
            return UInt64(truncatingIfNeeded: raw)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private let cxCombineIdentifierTypeInfo = try! typeInfo(of: CombineX.CombineIdentifier.self)

#endif
