#if CX_LOCK_FREE_ATOMIC
@_implementationOnly import Atomics
private let counter = UnsafeAtomic<UInt64>.create(0)
#else
#if !COCOAPODS
import CXUtility
#endif
private let counter = LockedAtomic<UInt64>(0)
#endif

public struct CombineIdentifier: Hashable, CustomStringConvertible {
    
    private let value: UInt64
    
    public init() {
        #if CX_LOCK_FREE_ATOMIC
        self.value = counter.loadThenWrappingIncrement(ordering: .relaxed)
        #else
        self.value = counter.loadThenWrappingIncrement()
        #endif
    }
    
    public init(_ obj: AnyObject) {
        self.value = UInt64(truncatingIfNeeded: UInt(bitPattern: ObjectIdentifier(obj)))
    }
    
    public var description: String {
        return "0x" + String(self.value, radix: 16)
    }
}
