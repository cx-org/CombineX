# CombineX([中文](README.zh_cn.md))

[![travis](https://img.shields.io/travis/cx-org/CombineX.svg)](https://travis-ci.org/cx-org/CombineX)
[![release](https://img.shields.io/github/release-pre/cx-org/combinex)](https://github.com/cx-org/CombineX/releases)
![install](https://img.shields.io/badge/install-spm%20%7C%20cocoapods%20%7C%20carthage-ff69b4)
![platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey)
![license](https://img.shields.io/github/license/cx-org/combinex?color=black)
[![dicord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/cresT3X)

`CombineX` is an open source implementation for Apple's [Combine](https://developer.apple.com/documentation/combine). It provides a completely consistent API with `Combine`, freeing you from the limitations of the version and platform.

## Notice

This library is still in beta, so **do not use it in production!**

🐱

## Contributing (｡◕‿◕｡✿)

Want to get involved? Awesome! **`CombineX` really needs your help now!**

You can：

- Finding bug
- Improving implementation
- Discussing in issues
- Reviewing pull request

Or just star! Then tell your friends!

### Testing

What `CombineX` need most are testing, using more test cases to ensure consistency of its behavior with `Combine`. The rules of adding tests are:

1. Add more functional tests.
2. Make sure `Specs` can pass it.
3. If `CombineX` can not pass it, then you have found a `CombineX`'s bug, you can open an issue, or fix it directly!


### Detailed Flow

Since some people may not have macOS 10.15 beta installed, the recommended contributing way is:

1. Fork the project.
2. Open `Specs/Specs.xcworkspace`, make your changes under `CombineX/CombineX` folder.
3. All tests go `CombineXTests/CombineXTests` folder. Make sure both scheme `Specs` and scheme `CombineX` pass the tests you wrote.

## What is Combine

`Combine` is a reactive framework launched by Apple at WWDC 2019, which refers to the interface design of [ReactiveX](http://reactivex.io/) and provides Apple's preferred implementation for Swift asynchronous programming. It will definitely be the cornerstone of Swift programming in the foreseeable future.

## What is CombineX

`CombineX` is an open source implementation of `Combine`. In addition to having an API consistent with `Combine`, it has the following advantages:

### 1. Versions and Platforms

`Combine` has very high version restrictions: macOS 10.15+, iOS 13+. This means, even if your app only needs to be compatible with two versions forward, it will take two to three years before you can use `Combine`. Moreover, `Combine` is exclusive to the Apple platform and does not support Linux, so you can't share one codebase between apple and linux.

`CombineX` helps you get rid of these limitations, it supports macOS 10.10+, iOS 8+, and supports Linux. With `CombineX`, you can use the same code on more platforms and versions.

### 2. Open source

`Combine` is closed source, it is like `UIKit`, `MapKit`, etc., updated with the update of Xcode. When you encounter a bug, "you should have encountered a system library bug", debugging is very annoying, but more annoying is the slow official response, usually, you can't do anything but wait for the next regular update of Xcode.

`CombineX` is completely open source, in addition to being able to debug line by line, you can get faster community response!

### 3. Extensions

`CombineX` provides a number of related extensions, including but not limited to:

- [CXFoundation](https://github.com/cx-org/CXFoundation): provides all `Foundation` extension implementations, built on top of `CombineX`. For example, `URLSession`, `NotificationCenter`, `Timer`, `DispatchQueue+Scheduler`, `RunLoop+Scheduler`, etc.
- [CXCompatible](https://github.com/cx-org/CXCompatible): provides API Shims for `CombineX` to help you resolve migration concerns that may arise. With this library, you can easily switch the dependency from `CombineX` to `Combine` at any time.

With `CombineX`, you are free to develop `Combine` related frameworks without worrying about version and platform limitations:

- [CXCocoa](https://github.com/cx-org/CXCocoa): provides `Cocoa` extension implementations, such as `KVOPublisher`, `MethodInterceptionPublisher`, `UIBinding`, etc.
- [CXExtensions](https://github.com/cx-org/CXExtensions): provides a collection of useful extensions for `Combine`, such as `DiscardError`, `DelayedAutoCancellable`, etc.

<p align="center">
<img src="demo.1.gif" height="500">
<img src="demo.2.gif" height="500">
</p>

## Install

### Swift Package Manager

```swift
dependencies.append(
    .package(url: "https://github.com/cx-org/CombineX", .branch("master"))
)
```

### CocoaPods

```ruby
pod 'CombineX', :git => 'https://github.com/cx-org/CombineX.git', :branch => 'master'
```

### Carthage

```carthage
github "cx-org/CombineX" "master"
```

## Bugs in Combine

Since `Combine` is still in beta, it is inevitable that it has bugs. If you find something strange, open an issue and discuss it with us!
