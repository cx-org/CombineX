import Foundation
import Nimble

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

public func beNotNil<T>() -> Predicate<T> {
    return Predicate.simpleNilable("be not nil") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return PredicateStatus(bool: actualValue != nil)
    }
}

public func beNotIdenticalTo(_ expected: Any?) -> Predicate<Any> {
    return Predicate.define { actualExpression in
        let actual = try actualExpression.evaluate() as AnyObject?

        let bool = actual !== (expected as AnyObject?) && actual !== nil
        return PredicateResult(
            bool: bool,
            message: .expectedCustomValueTo(
                "be not identical to \(identityAsString(expected))",
                actual: "\(identityAsString(actual))"
            )
        )
    }
}

private func identityAsString(_ value: Any?) -> String {
    let anyObject = value as AnyObject?
    if let value = anyObject {
        return NSString(format: "<%p>", unsafeBitCast(value, to: Int.self)).description
    } else {
        return "nil"
    }
}
