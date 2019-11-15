import Combine
import CombineX
import CXNamespace

// MARK: - From Combine

extension Combine.Cancellable {
    
    public var cx: CombineX.AnyCancellable {
        return CombineX.AnyCancellable(cancel)
    }
}

// MARK: - To Combine

extension CombineX.Cancellable {
    
    public var ac: Combine.AnyCancellable {
        return Combine.AnyCancellable(cancel)
    }
}
