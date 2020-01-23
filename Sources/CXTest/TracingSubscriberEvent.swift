import CXShim

public enum TracingSubscriberEvent<Input, Failure: Error> {
    case value(Input)
    case completion(Subscribers.Completion<Failure>)
}

public extension TracingSubscriberEvent {
    
    func isFinished() -> Bool {
        switch self {
        case .value:                return false
        case .completion(let c):    return c.isFinished
        }
    }
    
    var value: Input? {
        switch self {
        case .value(let v): return v
        case .completion:   return nil
        }
    }
    
    var error: Failure? {
        guard case .completion(let c) = self, case .failure(let e) = c else {
            return nil
        }
        return e
    }
    
    func mapError<NewFailure: Error>(_ transform: (Failure) -> NewFailure) -> TracingSubscriberEvent<Input, NewFailure> {
        switch self {
        case .value(let i):         return .value(i)
        case .completion(let c):    return .completion(c.mapError(transform))
        }
    }
}

public extension TracingSubscriberEvent where Input: Equatable {
    
    func isValue(_ value: Input) -> Bool {
        switch self {
        case .value(let v):     return v == value
        case .completion:       return false
        }
    }
}

extension TracingSubscriberEvent: Equatable where Input: Equatable, Failure: Equatable {}

extension TracingSubscriberEvent: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .value(let v):
            return "\(v)"
        case .completion(let c):
            return "\(c)"
        }
    }
}

public protocol TestEventProtocol {
    associatedtype Input
    associatedtype Failure: Error
    
    var testEvent: TracingSubscriberEvent<Input, Failure> {
        get set
    }
}

extension TracingSubscriberEvent: TestEventProtocol {
    
    public var testEvent: TracingSubscriberEvent<Input, Failure> {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

extension Collection where Element: TestEventProtocol {
    
    public func mapError<NewFailure: Error>(_ transform: (Element.Failure) -> NewFailure) -> [TracingSubscriberEvent<Element.Input, NewFailure>] {
        return self.map {
            $0.testEvent.mapError(transform)
        }
    }
}
