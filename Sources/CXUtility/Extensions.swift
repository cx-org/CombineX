extension FixedWidthInteger {
    
    public func multipliedClamping(by rhs: Self) -> Self {
        let (value, overflow) = multipliedReportingOverflow(by: rhs)
        return overflow ? .max : value
    }
}
