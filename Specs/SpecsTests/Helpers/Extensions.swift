import Foundation

#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

// MARK: - Subscribers.Completion

extension Subscribers.Completion {
    
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> Subscribers.Completion<NewFailure> {
        switch self {
        case .finished:
            return .finished
        case .failure(let error):
            return .failure(transform(error))
        }
    }
}


// MARK: - Test

// MARK: - Subscribers.Completion

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

// MARK: - Int

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


// MARK: - Optional
extension Optional {
    
    var isNil: Bool {
        return self == nil
    }
    
    var isNotNil: Bool {
        return self != nil
    }
}

// MAKR: Array
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

// MARK: DispatchQueue
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
