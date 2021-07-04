# CombineX

[![Github CI Status](https://github.com/cx-org/CombineX/workflows/CI/badge.svg)](https://github.com/cx-org/CombineX/actions)
[![Release](https://img.shields.io/github/release-pre/cx-org/combinex)](https://github.com/cx-org/CombineX/releases)
![Install](https://img.shields.io/badge/install-Swift_PM%20%7C%20CocoaPods%20%7C%20Carthage-ff69b4)
![Supported Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey)
[![Discord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/9vzqgZx)

[简体中文](README_zh-Hans.md)

Open-source implementation of Apple's [Combine](https://developer.apple.com/documentation/combine) for processing values over time.

> Though CombineX have implemented all the Combine interface, the project is still in early development.

## What is Combine

> Customize handling of asynchronous events by combining event-processing operators. -- Apple

`Combine` is a [Functional Reactive Programming (FRP)](https://en.wikipedia.org/wiki/Functional_reactive_programming) framework launched by Apple at WWDC 2019. It will definitely be the cornerstone of Swift programming in the foreseeable future.

## Get Started

> If you develop a library, it's recommended to use [`CXShim`](https://github.com/cx-org/CXShim) so your library is compatible with SwiftUI.

### Requirements

- Swift 5.0+ (Xcode 10.2+)

### Installation

#### Swift Package Manager (Recommended)

```swift
package.dependencies += [
    .package(url: "https://github.com/cx-org/CombineX", from: "0.4.0"),
]
```

#### CocoaPods

```ruby
pod 'CombineX', "~> 0.4.0"

# or, if you want to use `Foundation` extensions: 
pod 'CombineX/CXFoundation', "~> 0.4.0"
```

#### Carthage

```carthage
github "cx-org/CombineX" ~> 0.4.0
```

## Related Projects

These libraries bring additional functionality to Combine. They are all [Combine Compatible Package](https://github.com/cx-org/CombineX/wiki/Combine-Compatible-Package) and you're free to switch underlying Combine implementation between `CombineX` and Apple's `Combine`.

- [CXTest](https://github.com/cx-org/CXTest): test infrastructure for Combine. It provides useful test utilities like `TracingSubscriber` and `VirtualTimeScheduler`.
- [CXExtensions](https://github.com/cx-org/CXExtensions): provides a collection of useful extensions for Combine, such as `IgnoreError`, `DelayedAutoCancellable`, etc.
- [CXCocoa](https://github.com/cx-org/CXCocoa): provides Combine extensions to `Cocoa`, such as `KVO+Publisher`, `Method Interception`, `UIBinding`, `Delegate Proxy`, etc.

## License

CombineX is released under the MIT license. See [LICENSE](LICENSE) for details.

The following files are adapted from the Swift open source project:

- [Publishers+KeyValueObserving](Sources/CXFoundation/Publishers+KeyValueObserving.swift)
