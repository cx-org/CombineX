@usableFromInline
func WaitForImplementation(_ function: StaticString = #function) -> Never {
    fatalError("\(function) is waiting for implementation.")
}
