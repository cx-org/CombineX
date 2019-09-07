public protocol ResultProtocol {
    
    associatedtype Success
    associatedtype Failure: Error
    
    var result: Result<Success, Failure> {
        set get
    }
}

extension Result: ResultProtocol {
    
    public var result: Result {
        get { return self }
        set { self = newValue }
    }
}
