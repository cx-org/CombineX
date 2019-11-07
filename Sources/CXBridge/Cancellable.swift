import Combine
import CombineX

// MARK: - From Combine

extension Combine.Cancellable {
    
    public var cx: CombineX.AnyCancellable {
        return CombineX.AnyCancellable(cancel)
    }
}

// MARK: - To Combine

extension CombineX.Cancellable {
    
    public var combine: Combine.AnyCancellable {
        return Combine.AnyCancellable(cancel)
    }
}
