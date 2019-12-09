// This file is based largely on the Runtime package - https://github.com/wickwirew/Runtime

import CCombineX

struct PublishedFieldsIterator: IteratorProtocol {
    
    typealias Element = (storage: UnsafeMutableRawPointer, type: _PublishedProtocol.Type)
    
    private let object: UnsafeMutableRawPointer
    private var inheritanceIterator: UnfoldSequence<Any.Type, Any.Type?>.Iterator
    private var fieldsIterator: SwiftClassFieldsEnumerator.Iterator?
    
    init(object: UnsafeMutableRawPointer, type: Any.Type) {
        self.object = object
        self.inheritanceIterator = inheritance(type: type).makeIterator()
    }
    
    mutating func next() -> Element? {
        while let (offset, type) = nextField() {
            if let pType = type as? _PublishedProtocol.Type {
                let storage = object.advanced(by: offset)
                return (storage, pType)
            }
        }
        return nil
    }
    
    private mutating func nextField() -> (Int, Any.Type)? {
        if let next = fieldsIterator?.next() {
            return next
        }
        guard let type = inheritanceIterator.next() else {
            return nil
        }
        fieldsIterator = SwiftClassFieldsEnumerator(type: type).makeIterator()
        return nextField()
    }
}

private func inheritance(type: Any.Type) -> UnfoldSequence<Any.Type, Any.Type?> {
    return sequence(state: Optional(type)) { type -> Any.Type? in
        guard let unwrappedType = type else {
            return nil
        }
        let typePtr = unsafeBitCast(unwrappedType, to: UnsafeMutableRawPointer.self)
        
        let kind = typePtr.assumingMemoryBound(to: UInt.self).pointee
        guard kind >= 0x800 else {
            // not a class object
            return nil
        }
        
        let data = typePtr.assumingMemoryBound(to: AnyClassMetadata.self).pointee.rodataPointer
        guard (data & classIsSwiftMask) != 0 else {
            // pure-objc class
            return nil
        }
        
        let classMetadataPtr = typePtr.assumingMemoryBound(to: ClassMetadata.self)
        let classTypeDescriptorPtr = classMetadataPtr.pointee.typeDescriptor
        guard !classTypeDescriptorPtr.pointee.hasResilientSuperclass else {
            // resilient subclass
            return nil
        }
        
        defer {
            let superClass = classMetadataPtr.pointee.superClass
            type = (superClass == swiftObject) ? nil : superClass
        }
        
        return unwrappedType
    }
}

private struct SwiftClassFieldsEnumerator: RandomAccessCollection {
    
    private let fieldOffsets: UnsafePointer<Int>
    private let fieldRecords: UnsafeMutablePointer<FieldDescriptor.Record>
    private let genericContext: UnsafeMutablePointer<ClassTypeDescriptor>
    private let genericArguments: UnsafeMutablePointer<Any.Type>
    
    let startIndex = 0
    let endIndex: Int
    
    subscript(position: Int) -> (Int, Any.Type) {
        let offset = fieldOffsets[position]
        let type = fieldRecords
            .advanced(by: position)
            .pointee
            .type(genericContext: genericContext, genericArguments: genericArguments)
        return (offset, type)
    }
    
    init(type: Any.Type) {
        let typePtr = unsafeBitCast(type, to: UnsafeMutableRawPointer.self)
        let metadata = typePtr.assumingMemoryBound(to: ClassMetadata.self)
        let typeDescriptor = metadata.pointee.typeDescriptor
        endIndex = Int(typeDescriptor.pointee.numberOfFields)
        fieldOffsets = typeDescriptor.pointee.offsetToTheFieldOffsetBuffer.pointer(metadata: typePtr)
        fieldRecords = typeDescriptor.pointee.fieldDescriptor.advanced().pointee.fields.pointer()
        genericContext = metadata.pointee.typeDescriptor
        genericArguments = typePtr
            .advanced(by: typeDescriptor.pointee.genericArgumentOffset)
            .assumingMemoryBound(to: Any.Type.self)
    }
}

// MARK: - Layout

private struct AnyClassMetadata {
    var _kind: Int // isaPointer for classes
    var superClass: Any.Type
    var cacheData: (Int, Int)
    var rodataPointer: Int
}

private struct ClassMetadata {
    var _kind: Int // isaPointer for classes
    var superClass: Any.Type
    var cacheData: (Int, Int)
    var rodataPointer: Int
    var classFlags: Int32
    var instanceAddressPoint: UInt32
    var instanceSize: UInt32
    var instanceAlignmentMask: UInt16
    var reserved: UInt16
    var classSize: UInt32
    var classAddressPoint: UInt32
    var typeDescriptor: UnsafeMutablePointer<ClassTypeDescriptor>
    var iVarDestroyer: UnsafeRawPointer
}

private struct ClassTypeDescriptor {
    var flags: Int32
    var parent: Int32
    var mangledName: RelativePointer<Int32, CChar>
    var fieldTypesAccessor: RelativePointer<Int32, Int>
    var fieldDescriptor: RelativePointer<Int32, FieldDescriptor>
    var superClass: RelativePointer<Int32, Any.Type>
    var negativeSizeAndBoundsUnion: Int32
    var metadataPositiveSizeInWords: Int32
    var numImmediateMembers: Int32
    var numberOfFields: Int32
    var offsetToTheFieldOffsetBuffer: RelativeBufferPointer<Int32, Int>
//    var genericContextHeader: TargetTypeGenericContextDescriptorHeader
    
    var hasResilientSuperclass: Bool {
        return ((flags >> 16) & 0x2000) != 0
    }
    
    var areImmediateMembersNegative: Bool {
        return ((flags >> 16) & 0x1000) != 0
    }
    
    var genericArgumentOffset: Int {
        guard !hasResilientSuperclass else {
            fatalError("Cannot get the `genericArgumentOffset` for classes with a resilient superclass")
        }
        let strides = areImmediateMembersNegative
            ? Int(-negativeSizeAndBoundsUnion)
            : Int(metadataPositiveSizeInWords - numImmediateMembers)
        return strides * MemoryLayout<UnsafeRawPointer>.size
    }
}

private struct FieldDescriptor {
    var mangledTypeNameOffset: Int32
    var superClassOffset: Int32
    var _kind: UInt16
    var fieldRecordSize: Int16
    var numFields: Int32
    var fields: Buffer<Record>
    
    struct Record {
        
        var fieldRecordFlags: Int32
        var _mangledTypeName: RelativePointer<Int32, Int8>
        var _fieldName: RelativePointer<Int32, UInt8>
        
        mutating func type(genericContext: UnsafeRawPointer?,
                           genericArguments: UnsafeRawPointer?) -> Any.Type {
            let typeName = _mangledTypeName.advanced()
            let metadataPtr = swift_getTypeByMangledNameInContext(
                typeName,
                getSymbolicMangledNameLength(typeName),
                genericContext,
                genericArguments?.assumingMemoryBound(to: Optional<UnsafeRawPointer>.self)
            )!
            
            return unsafeBitCast(metadataPtr, to: Any.Type.self)
        }
        
        func getSymbolicMangledNameLength(_ base: UnsafeRawPointer) -> Int32 {
            var end = base
            while let current = Optional(end.load(as: UInt8.self)), current != 0 {
                end += 1
                if current >= 0x1 && current <= 0x17 {
                    end += 4
                } else if current >= 0x18 && current <= 0x1F {
                    end += MemoryLayout<Int>.size
                }
            }
            return Int32(end - base)
        }
    }
}

// MARK: - Pointers

private struct Buffer<Element> {
    
    var element: Element
    
    mutating func pointer() -> UnsafeMutablePointer<Element> {
        return withUnsafePointer(to: &self) {
            return UnsafeMutableRawPointer(mutating: UnsafeRawPointer($0))
                .assumingMemoryBound(to: Element.self)
        }
    }
}

private struct RelativePointer<Offset: FixedWidthInteger, Pointee> {
    
    var offset: Offset
    
    mutating func advanced() -> UnsafeMutablePointer<Pointee> {
        let offset = self.offset
        return withUnsafePointer(to: &self) { p in
            return UnsafeMutableRawPointer(mutating: p)
                .advanced(by: numericCast(offset))
                .assumingMemoryBound(to: Pointee.self)
        }
    }
}

private struct RelativeBufferPointer<Offset: FixedWidthInteger, Pointee> {
    
    var strides: Offset
    
    func pointer(metadata: UnsafeRawPointer) -> UnsafePointer<Pointee> {
        let offset = numericCast(strides) * MemoryLayout<UnsafeRawPointer>.size
        return metadata.advanced(by: offset).assumingMemoryBound(to: Pointee.self)
    }
}

// MARK: -

private var swiftObject: Any.Type = {
    class Temp {}
    return unsafeBitCast(Temp.self, to: UnsafeRawPointer.self)
        .assumingMemoryBound(to: ClassMetadata.self)
        .pointee
        .superClass
}()

private var classIsSwiftMask: Int = {
    #if canImport(Darwin)
    if #available(macOS 10.14.4, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
        return 2
    }
    #endif
    return 1
}()
