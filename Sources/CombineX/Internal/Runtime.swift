// This file is based largely on the Runtime package - https://github.com/wickwirew/Runtime

struct PublishedFieldsEnumerator: Sequence {
    
    fileprivate typealias InheritanceSequence = UnfoldSequence<Any.Type, Any.Type>
    
    struct Iterator: IteratorProtocol {
        
        typealias Element = (storage: UnsafeMutableRawPointer, type: _ObservableObjectProperty.Type)
        
        private let object: UnsafeMutableRawPointer
        private var inheritanceIterator: InheritanceSequence.Iterator
        private var fieldsIterator: SwiftClassFieldsEnumerator.Iterator?
        
        fileprivate init(object: UnsafeMutableRawPointer, inheritance: InheritanceSequence.Iterator) {
            self.object = object
            self.inheritanceIterator = inheritance
        }
        
        mutating func next() -> Element? {
            while let (offset, type) = nextField() {
                if let pType = type as? _ObservableObjectProperty.Type {
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
            fieldsIterator = SwiftClassFieldsEnumerator(type).makeIterator()
            return nextField()
        }
    }
    
    private let object: UnsafeMutableRawPointer
    private let type: Any.Type
    
    init(object: UnsafeMutableRawPointer, type: Any.Type) {
        self.object = object
        self.type = type
    }
    
    func makeIterator() -> Iterator {
        return Iterator(object: object, inheritance: inheritance().makeIterator())
    }
    
    private func inheritance() -> InheritanceSequence {
        return sequence(state: type) { state in
            let typePtr = unsafeBitCast(state, to: UnsafeMutableRawPointer.self)
            guard state != swiftObject,
                typePtr.assumingMemoryBound(to: AnyMetadata.self).pointee.isClass,
                typePtr.assumingMemoryBound(to: AnyClassMetadata.self).pointee.isSwiftClass else {
                return nil
            }
            let classMetadataPtr = typePtr.assumingMemoryBound(to: ClassMetadata.self)
            guard !classMetadataPtr.pointee.typeDescriptor.pointee.hasResilientSuperclass else {
                // resilient subclass
                return nil
            }
            defer {
                state = classMetadataPtr.pointee.superClass
            }
            return state
        }
    }
}

private struct SwiftClassFieldsEnumerator: RandomAccessCollection {
    
    private let fieldOffsets: UnsafePointer<Int>
    private let fieldRecords: UnsafeMutablePointer<FieldDescriptor.Record>
    private let genericContext: UnsafeMutablePointer<ClassTypeDescriptor>
    private let genericArguments: UnsafeMutablePointer<Any.Type>
    
    let startIndex = 0
    let endIndex: Int
    
    init(_ type: Any.Type) {
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
    
    subscript(position: Int) -> (Int, Any.Type) {
        let offset = fieldOffsets[position]
        let type = fieldRecords
            .advanced(by: position)
            .pointee
            .type(genericContext: genericContext, genericArguments: genericArguments)
        return (offset, type)
    }
}

// MARK: - Layout

private struct AnyMetadata {
    var _kind: UInt
    
    var isClass: Bool {
        return _kind == 0 || _kind >= 0x800
    }
}

private struct AnyClassMetadata {
    var _kind: UInt // isaPointer for classes
    var superClass: Any.Type
    var cacheData: (Int, Int)
    var rodataPointer: Int
    
    var isSwiftClass: Bool {
        return (rodataPointer & classIsSwiftMask) != 0
    }
}

private struct ClassMetadata {
    var _kind: UInt // isaPointer for classes
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
        var _mangledTypeName: RelativePointer<Int32, UInt8>
        var _fieldName: RelativePointer<Int32, UInt8>
        
        mutating func type(genericContext: UnsafeRawPointer?,
                           genericArguments: UnsafeRawPointer?) -> Any.Type {
            let typeName = _mangledTypeName.advanced()
            let metadataPtr = _getTypeByMangledNameInContext(
                typeName,
                getSymbolicMangledNameLength(typeName),
                genericContext: genericContext,
                genericArguments: genericArguments)
            return metadataPtr!
        }
        
        func getSymbolicMangledNameLength(_ base: UnsafeRawPointer) -> UInt {
            var end = base
            while let current = Optional(end.load(as: UInt8.self)), current != 0 {
                end += 1
                if current >= 0x1 && current <= 0x17 {
                    end += 4
                } else if current >= 0x18 && current <= 0x1F {
                    end += MemoryLayout<Int>.size
                }
            }
            return UInt(end - base)
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

// MARK: - Const

private let swiftObject: Any.Type = {
    class Temp {}
    return unsafeBitCast(Temp.self, to: UnsafeRawPointer.self)
        .assumingMemoryBound(to: ClassMetadata.self)
        .pointee
        .superClass
}()

private let classIsSwiftMask: Int = {
    #if canImport(Darwin)
    if #available(macOS 10.14.4, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
        return 2
    }
    #endif
    return 1
}()

@_silgen_name("swift_getTypeByMangledNameInContext")
private func _getTypeByMangledNameInContext(
    _ name: UnsafePointer<UInt8>,
    _ nameLength: UInt,
    genericContext: UnsafeRawPointer?,
    genericArguments: UnsafeRawPointer?)
    -> Any.Type?
