import CCombineX

private var classIsSwiftMask: Int = {
    #if canImport(Darwin)
    if #available(macOS 10.14.4, iOS 12.2, tvOS 12.2, watchOS 5.2, *) {
        return 2
    }
    #endif
    return 1
}()

func enumerateClassFields(type: Any.Type, body: (Int, Any.Type) -> Bool) -> Bool {
    let typePtr = unsafeBitCast(type, to: UnsafeMutableRawPointer.self)
    
    let kind = typePtr.assumingMemoryBound(to: UInt.self).pointee
    guard kind >= 0x800 else {
        // not a class object
        return false
    }
    
    let data = typePtr.assumingMemoryBound(to: AnyClassMetadataLayout.self).pointee.rodataPointer
    guard (data & classIsSwiftMask) != 0 else {
        // pure-objc class
        return true
    }
    
    let classMetadataPtr = typePtr.assumingMemoryBound(to: ClassMetadataLayout.self)
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
        let recordPtr = fieldDescriptorPtr.pointee.fields.element(at: i)
        
        let offset = fieldOffsetsPtr[i]
        let genericArguments = typePtr.advanced(by: classMetadataPtr.pointee.genericArgumentOffset * MemoryLayout<UnsafeRawPointer>.size).assumingMemoryBound(to: Buffer<Any.Type>.self).pointee.element(at: 0)
        let type = recordPtr.pointee.type(genericContext: classMetadataPtr.pointee.typeDescriptor, genericArguments: genericArguments)
        if !body(offset, type) {
            return false
        }
    }
    
    return true
}

struct AnyClassMetadataLayout {
    var _kind: Int // isaPointer for classes
    var superClass: Any.Type
    var cacheData: (Int, Int)
    var rodataPointer: Int
}

struct ClassMetadataLayout {
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
        return (0x800 & classFlags) != 0
    }
    
    var genericArgumentOffset: Int {
        if !hasResilientSuperclass {
            return areImmediateMembersNegative
                ? -Int(typeDescriptor.pointee.negativeSizeAndBoundsUnion)
                : Int(typeDescriptor.pointee.metadataPositiveSizeInWords - typeDescriptor.pointee.numImmediateMembers)
        }
        
        /*
        let storedBounds = typeDescriptor.pointee
            .negativeSizeAndBoundsUnion
            .resilientMetadataBounds()
            .pointee
            .advanced()
            .pointee
        */
        
        // To do this something like `computeMetadataBoundsFromSuperclass` in Metadata.cpp
        // will need to be implemented. To do that we also need to get the resilient superclass
        // from the trailing objects.
        fatalError("Cannot get the `genericArgumentOffset` for classes with a resilient superclass")
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

struct Buffer<Element> {
    
    var element: Element
    
    mutating func buffer(n: Int) -> UnsafeBufferPointer<Element> {
        return withUnsafePointer(to: &self) {
            return UnsafeBufferPointer(start: UnsafeRawPointer($0).assumingMemoryBound(to: Element.self), count: n)
        }
    }
    
    mutating func element(at i: Int) -> UnsafeMutablePointer<Element> {
        return withUnsafePointer(to: &self) {
            return UnsafeMutablePointer(mutating: UnsafeRawPointer($0).assumingMemoryBound(to: Element.self).advanced(by: i))
        }
    }
}

struct RelativePointer<Offset: FixedWidthInteger, Pointee> {
    
    var offset: Offset
    
    mutating func pointee() -> Pointee {
        return advanced().pointee
    }
    
    mutating func advanced() -> UnsafeMutablePointer<Pointee> {
        let offset = self.offset
        return withUnsafePointer(to: &self) { p in
            return UnsafeMutableRawPointer(mutating: p).advanced(by: numericCast(offset))
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
        
        var isVar: Bool {
            return (fieldRecordFlags & 0x2) == 0x2
        }
        
        mutating func fieldName() -> String {
            return String(cString: _fieldName.advanced())
        }
        
        mutating func mangedTypeName() -> String {
            return String(cString: _mangledTypeName.advanced())
        }
        
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

private func swiftObject() -> Any.Type {
    class Temp {}
    return unsafeBitCast(Temp.self, to: UnsafeRawPointer.self).assumingMemoryBound(to: ClassMetadataLayout.self).pointee.superClass
}
