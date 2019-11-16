#if canImport(Combine)

import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.TopLevelEncoder {
    
    public var cx: CXWrappers.AnyTopLevelEncoder<Self> {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.TopLevelDecoder {
    
    public var cx: CXWrappers.AnyTopLevelDecoder<Self> {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CXWrappers {
    
    public struct AnyTopLevelEncoder<Base: Combine.TopLevelEncoder>: CXWrapper, CombineX.TopLevelEncoder {
        
        public typealias Output = Base.Output
        
        public var base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
        
        public func encode<T: Encodable>(_ value: T) throws -> Base.Output {
            return try base.encode(value)
        }
    }
    
    public struct AnyTopLevelDecoder<Base: Combine.TopLevelDecoder>: CXWrapper, CombineX.TopLevelDecoder {
        
        public typealias Input = Base.Input
        
        public var base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
        
        public func decode<T: Decodable>(_ type: T.Type, from: Base.Input) throws -> T {
            return try base.decode(type, from: from)
        }
    }
}

// MARK: - To Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.TopLevelEncoder {
    
    public var ac: ACWrappers.AnyTopLevelEncoder<Self> {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineX.TopLevelDecoder {
    
    public var ac: ACWrappers.AnyTopLevelDecoder<Self> {
        return .init(wrapping: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension ACWrappers {
    
    public struct AnyTopLevelEncoder<Base: CombineX.TopLevelEncoder>: ACWrapper, Combine.TopLevelEncoder {
        
        public typealias Output = Base.Output
        
        public var base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
        
        public func encode<T: Encodable>(_ value: T) throws -> Base.Output {
            return try base.encode(value)
        }
    }
    
    public struct AnyTopLevelDecoder<Base: CombineX.TopLevelDecoder>: ACWrapper, Combine.TopLevelDecoder {
        
        public typealias Input = Base.Input
        
        public var base: Base
        
        public init(wrapping base: Base) {
            self.base = base
        }
        
        public func decode<T: Decodable>(_ type: T.Type, from: Base.Input) throws -> T {
            return try base.decode(type, from: from)
        }
    }
}

#endif
