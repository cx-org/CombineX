import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

extension Combine.TopLevelEncoder {
    
    public var cx: CXWrappers.AnyTopLevelEncoder<Self> {
        return CXWrappers.AnyTopLevelEncoder(wrapping: self)
    }
}

extension Combine.TopLevelDecoder {
    
    public var cx: CXWrappers.AnyTopLevelDecoder<Self> {
        return CXWrappers.AnyTopLevelDecoder(wrapping: self)
    }
}

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

extension CombineX.TopLevelEncoder {
    
    public var ac: ACWrappers.AnyTopLevelEncoder<Self> {
        return ACWrappers.AnyTopLevelEncoder(wrapping: self)
    }
}

extension CombineX.TopLevelDecoder {
    
    public var ac: ACWrappers.AnyTopLevelDecoder<Self> {
        return ACWrappers.AnyTopLevelDecoder(wrapping: self)
    }
}

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
