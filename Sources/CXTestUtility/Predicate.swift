import Foundation
import Nimble

public func throwAssertion<T>() -> Predicate<T> {
    return Predicate { actualExpression in
        return try Nimble.throwAssertion().satisfies(actualExpression.cast { _ in })
    }
}

public func beAllEqual<S: Sequence, T: Equatable>() -> Predicate<S>
    where S.Iterator.Element == T {
    return Predicate.simple("element be all equal") { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else {
            return .fail
        }
        var actualGenerator = actualValue.makeIterator()
        if let first = actualGenerator.next() {
            while let next = actualGenerator.next() {
                if next != first {
                    return .doesNotMatch
                }
            }
        }
        return .matches
    }
}
