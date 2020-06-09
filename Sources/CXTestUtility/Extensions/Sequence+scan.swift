extension Sequence {
    
    public func scan<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> [Result] {
        var partialResult = initialResult
        return map { element in
            partialResult = nextPartialResult(partialResult, element)
            return partialResult
        }
    }
}
