#if USE_COMBINE
import Combine
#elseif SWIFT_PACKAGE
import CombineX
#else
import Specs
#endif

enum TestSubscriberEvent<Input, Failure: Error> {
    case value(Input)
    case completion(Subscribers.Completion<Failure>)
}

extension TestSubscriberEvent {
    
    func isFinished() -> Bool {
        switch self {
        case .value:                return false
        case .completion(let c):    return c.isFinished
        }
    }
    
    var error: Failure? {
        guard case .completion(let c) = self, case .failure(let e) = c else {
            return nil
        }
        return e
    }
    
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> TestSubscriberEvent<Input, NewFailure> {
        switch self {
        case .value(let i):         return .value(i)
        case .completion(let c):    return .completion(c.mapError(transform))
        }
    }
}

extension TestSubscriberEvent where Input: Equatable {
    
    func isValue(_ value: Input) -> Bool {
        switch self {
        case .value(let v):     return v == value
        case .completion:       return false
        }
    }
}

extension TestSubscriberEvent: Equatable where Input: Equatable, Failure: Equatable {
    
    static func == (lhs: TestSubscriberEvent, rhs: TestSubscriberEvent) -> Bool {
        switch (lhs, rhs) {
        case (.value(let a), .value(let b)):            return a == b
        case (.completion(let a), .completion(let b)):
            switch (a, b) {
            case (.finished, .finished):                return true
            case (.failure(let e0), .failure(let e1)):  return e0 == e1
            default:                                    return false
            }
        default:                                        return false
        }
    }
}

extension TestSubscriberEvent: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .value(let v):
            return "\(v)"
        case .completion(let c):
            return "\(c)"
        }
    }
}

protocol TestEventProtocol {
    associatedtype Input
    associatedtype Failure: Error
    
    var testEvent: TestSubscriberEvent<Input, Failure> {
        get set
    }
}

extension TestSubscriberEvent: TestEventProtocol {
    
    var testEvent: TestSubscriberEvent<Input, Failure> {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension Collection where Element: TestEventProtocol {
    
    func mapError<NewFailure: Error>(_ transform: (Element.Failure) -> NewFailure) -> [TestSubscriberEvent<Element.Input, NewFailure>] {
        return self.map {
            $0.testEvent.mapError(transform)
        }
    }
}
