import CCombineX

func enumerateClassFields(type: Any.Type, body: (Int, Any.Type) -> Bool) -> Bool {
    let typePtr = unsafeBitCast(type, to: UnsafeMutableRawPointer.self)
    
    let kind = typePtr.assumingMemoryBound(to: UInt.self).pointee
    guard kind >= 0x800 else {
        // not a class object
        return false
    }
    
    let data = typePtr.assumingMemoryBound(to: AnyClassMetadata.self).pointee.rodataPointer
    guard (data & classIsSwiftMask) != 0 else {
        // pure-objc class
        return true
    }
    
    let classMetadataPtr = typePtr.assumingMemoryBound(to: ClassMetadata.self)
    guard !classMetadataPtr.pointee.hasResilientSuperclass else {
        // resilient subclass
        return true
    }
    
    let superClass = classMetadataPtr.pointee.superClass
    // type comparison directly to NSObject.self does not work.
    // just compare the type name instead.
    if superClass != swiftObject() && "\(superClass)" != "NSObject" {
        if !enumerateClassFields(type: superClass, body: body) {
            return false
        }
    }
    
    let classTypeDescriptorPtr = classMetadataPtr.pointee.typeDescriptor
    let numberOfFields = Int(classTypeDescriptorPtr.pointee.numberOfFields)
    let fieldOffsetsPtr = classTypeDescriptorPtr.pointee.offsetToTheFieldOffsetBuffer.buffer(metadata: typePtr, n: numberOfFields)
    let fieldDescriptorPtr = classTypeDescriptorPtr.pointee.fieldDescriptor.advanced()
    
    for i in 0..<numberOfFields {
        let offset = fieldOffsetsPtr[i]
        let recordPtr = fieldDescriptorPtr.pointee.fields[i]
        let genericArguments = typePtr.advanced(by: classMetadataPtr.pointee.genericArgumentOffset * MemoryLayout<UnsafeRawPointer>.size).assumingMemoryBound(to: Any.Type.self)
        let type = recordPtr.pointee.type(genericContext: classMetadataPtr.pointee.typeDescriptor, genericArguments: genericArguments)
        if !body(offset, type) {
            return false
        }
    }
    
    return true
}

struct AnyClassMetadata {
    var _kind: Int // isaPointer for classes
    var superClass: Any.Type
    var cacheData: (Int, Int)
    var rodataPointer: Int
}

struct ClassMetadata {
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
    
    var hasResilientSuperclass: Bool {
        return (classFlags & 0x4000) != 0
    }
    
    var areImmediateMembersNegative: Bool {
        return (classFlags & 0x800) != 0
    }
    
    var genericArgumentOffset: Int {
        guard !hasResilientSuperclass else {
            fatalError("Cannot get the `genericArgumentOffset` for classes with a resilient superclass")
        }
        return areImmediateMembersNegative
            ? -Int(typeDescriptor.pointee.negativeSizeAndBoundsUnion)
            : Int(typeDescriptor.pointee.metadataPositiveSizeInWords - typeDescriptor.pointee.numImmediateMembers)
    }
}

struct ClassTypeDescriptor {
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
}

struct FieldDescriptor {
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

struct Buffer<Element> {
    
    var element: Element
    
    subscript(i: Int) -> UnsafeMutablePointer<Element> {
        mutating get {
            return withUnsafePointer(to: &self) {
               return UnsafeMutablePointer(mutating: UnsafeRawPointer($0).assumingMemoryBound(to: Element.self).advanced(by: i))
            }
        }
    }
}

struct RelativePointer<Offset: FixedWidthInteger, Pointee> {
    
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

struct RelativeBufferPointer<Offset: FixedWidthInteger, Pointee> {
    
    var offset: Offset
    
    func buffer(metadata: UnsafeRawPointer, n: Int) -> UnsafeBufferPointer<Pointee> {
        let p = metadata.advanced(by: numericCast(offset) * MemoryLayout<UnsafeRawPointer>.size).assumingMemoryBound(to: Pointee.self)
        return UnsafeBufferPointer(start: p, count: n)
    }
}

private func swiftObject() -> Any.Type {
    class Temp {}
    return unsafeBitCast(Temp.self, to: UnsafeRawPointer.self).assumingMemoryBound(to: ClassMetadata.self).pointee.superClass
}

private var classIsSwiftMask: Int = {
    #if canImport(Darwin)
    if #available(macOS 10.14.4, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
        return 2
    }
    #endif
    return 1
}()
