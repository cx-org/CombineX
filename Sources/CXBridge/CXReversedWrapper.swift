import CXNamespace

protocol CXReversedWrapper {
    
    associatedtype CXBase
    
    var base: CXBase { get }
    
    init(wrapping base: CXBase)
}
