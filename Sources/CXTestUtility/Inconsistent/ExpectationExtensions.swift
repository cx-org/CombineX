import Foundation
import Nimble

public extension Expectation {
    
    func toFail(_ predicate: Predicate<T>, description: String? = nil) {
        #if USE_COMBINE
        to(predicate, description: description)
        #else
        toNot(predicate, description: description)
        #endif
    }
    
    func toFix(_ predicate: Predicate<T>, description: String? = nil) {
        #if USE_COMBINE
        toNot(predicate, description: description)
        #else
        to(predicate, description: description)
        #endif
    }
    
    func toBranch(combine combinePredicate: Predicate<T>, cx cxPredicate: Predicate<T>, description: String? = nil) {
        #if USE_COMBINE
        to(combinePredicate, description: description)
        #else
        to(cxPredicate, description: description)
        #endif
    }
}
