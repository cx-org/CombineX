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
    
    /// A textual representation of this instance.
    ///
    /// Calling this property directly is discouraged. Instead, convert an
    /// instance of any type to a string by using the `String(describing:)`
    /// initializer. This initializer works with any type, and uses the custom
    /// `description` property for types that conform to
    /// `CustomStringConvertible`:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
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
