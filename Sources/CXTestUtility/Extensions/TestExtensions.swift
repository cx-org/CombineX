import CXShim
import CXUtility
import Foundation

public extension Array {
    
    static func make(count: Int, make: @autoclosure () -> Element) -> [Element] {
        var elements: [Element] = []
        count.times {
            elements.append(make())
        }
        return elements
    }
}

public extension Array where Element: Equatable {
    
    func count(of e: Element) -> Int {
        return self.filter { $0 == e }.count
    }
}

public extension DispatchQueue {
    
    var isCurrent: Bool {
        let key = DispatchSpecificKey<Void>()
        self.setSpecific(key: key, value: ())
        defer {
            self.setSpecific(key: key, value: nil)
        }
        return DispatchQueue.getSpecific(key: key) != nil
    }
}

public extension Double {
    
    var clampedToInt: Int {
        switch self {
        case ...Double(Int.min):
            return Int.min
        case Double(Int.max)...:
            return Int.max
        default:
            return Int(self)
        }
    }
}

public extension Int {
    
    func times(_ body: (Int) -> Void) {
        guard self > 0 else {
            return
        }
        for i in 0..<self {
            body(i)
        }
    }
    
    func times(_ body: () -> Void) {
        self.times { _ in
            body()
        }
    }
}

extension CXWrappers.DispatchQueue.SchedulerTimeType.Stride {
    
    public var seconds: TimeInterval {
        return TimeInterval(magnitude) / TimeInterval(Const.nsec_per_sec)
    }
}
