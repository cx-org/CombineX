#if !COCOAPODS
import CXUtility
#endif

private let counter = Atom<UInt>(val: 0)

public struct CombineIdentifier : Hashable, CustomStringConvertible {
    
    private let id: UInt
    
    public init() {
        self.id = counter.add(1)
    }
    
    public init(_ obj: AnyObject) {
        self.id = UInt(bitPattern: ObjectIdentifier(obj))
    }
    
    public var description: String {
        return "0x" + String(self.id, radix: 16)
    }
    
    public var hashValue: Int {
        return self.id.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public static func == (a: CombineIdentifier, b: CombineIdentifier) -> Bool {
        return a.id == b.id
    }
}
