import CXShim

extension Subject {
    
    public func send<S: Sequence>(contentsOf values: S) where S.Element == Output {
        for value in values {
            send(value)
        }
    }
}
