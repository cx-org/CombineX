#if !COCOAPODS
import CXUtility
#endif

private let counter = Atom<UInt64>(val: 0)

public struct CombineIdentifier: Hashable, CustomStringConvertible {
    
    private let value: UInt64
    
    public init() {
        self.value = counter.add(1)
    }
    
    public init(_ obj: AnyObject) {
        self.value = UInt64(truncatingIfNeeded: UInt(bitPattern: ObjectIdentifier(obj)))
    }
    
    public var description: String {
        return "0x" + String(self.value, radix: 16)
    }
}
