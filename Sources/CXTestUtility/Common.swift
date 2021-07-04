@inline(never)
public func blackHole<T>(_ x: T) {
}

@inline(never)
public func identity<T>(_ x: T) -> T {
    return x
}
