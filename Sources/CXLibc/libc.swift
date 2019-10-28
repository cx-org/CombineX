#if os(Linux)

@_exported import Glibc

#elseif os(Windows)

@_exported import MSVCRT
@_exported import WinSDK

#else

@_exported import Darwin.C

#endif
