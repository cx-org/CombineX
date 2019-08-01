import Foundation
#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

extension Array {
    
    static func make(count: Int, make: @autoclosure () -> Element) -> [Element] {
        var elements: [Element] = []
        count.times {
            elements.append(make())
        }
        return elements
    }
}

extension Array where Element: Equatable {
    
    func count(of e: Element) -> Int {
        return self.filter { $0 == e }.count
    }
}


extension DispatchQueue {
    
    var isCurrent: Bool {
        let key = DispatchSpecificKey<Void>()
        self.setSpecific(key: key, value: ())
        defer {
            self.setSpecific(key: key, value: nil)
        }
        return DispatchQueue.getSpecific(key: key) != nil
    }
}


extension Double {
    
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

extension Int {
    
    func times(_ body: (Int) -> Void) {
        guard self > 0 else {
            return
        }
        for i in 0..<self {
            body(i)
        }
    }
    
    func times(_ body: () -> Void) {
        self.times { (_) in
            body()
        }
    }
}


extension Optional {
    
    var isNil: Bool {
        return self == nil
    }
    
    var isNotNil: Bool {
        return self != nil
    }
}

extension Subscribers.Completion {
    
    var isFinished: Bool {
        switch self {
        case .finished:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        switch self {
        case .failure:
            return true
        case .finished:
            return false
        }
    }
}

