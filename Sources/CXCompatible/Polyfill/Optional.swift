#if canImport(Combine)

import Combine

extension Optional {
    
    @available(macOS, introduced: 10.15, obsoleted: 11.0)
    @available(iOS, introduced: 13.0, obsoleted: 14.0)
    @available(tvOS, introduced: 13.0, obsoleted: 14.0)
    @available(watchOS, introduced: 6.0, obsoleted: 7.0)
    public var publisher: Publisher {
        return Publisher(self)
    }
}

#endif
