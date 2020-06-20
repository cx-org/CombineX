# CombineX

[![Github CI Status](https://github.com/cx-org/CombineX/workflows/CI/badge.svg)](https://github.com/cx-org/CombineX/actions)
[![Release](https://img.shields.io/github/release-pre/cx-org/combinex)](https://github.com/cx-org/CombineX/releases)
![Install](https://img.shields.io/badge/install-Swift_PM%20%7C%20CocoaPods%20%7C%20Carthage-ff69b4)
![Supported Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey)
[![Discord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/9vzqgZx)

对 Apple [Combine](https://developer.apple.com/documentation/combine) 的开源实现。

> 虽然 CombineX 已经实现了 Combine 的全部功能，但这一项目仍处于早期开发阶段。

## 什么是 Combine

> Customize handling of asynchronous events by combining event-processing operators. -- Apple

`Combine` 是 Apple 在 WWDC 2019 上推出的[函数式响应式编程](https://zh.wikipedia.org/wiki/函数式反应式编程)框架。在可预见的将来，它一定会成为 Swift 编程的基石。

## 开始使用

### 要求

- Swift 5.0 (Xcode 10.2)

### 安装

#### Swift Package Manager (推荐)

```swift
package.dependencies += [
    .package(url: "https://github.com/cx-org/CombineX", from: "0.2.1"),
]
```

#### CocoaPods

```ruby
pod 'CombineX', "~> 0.2.1"
```

#### Carthage

```carthage
github "cx-org/CombineX" ~> 0.2.1
```

CXShim 仅在 Swift Package Manager 下可用。

## 相关项目

以下这些库为 Combine 添加了额外功能。它们都是 [Combine 兼容库](https://github.com/cx-org/CombineX/wiki/Combine-Compatible-Package)，你可以自由切换底层的 Combine 实现，以使用 CombineX 或是 Apple 提供的 Combine。

- [CXCocoa](https://github.com/cx-org/CXCocoa)：提供 `Cocoa` 的 `Combine` 扩展。例如 `KVO+Publisher`，`Method Interception`，`UIBinding`，`Delegate Proxy` 等。
- [CXExtensions](https://github.com/cx-org/CXExtensions)：提供一系列有用的 Combine 扩展，例如：`IgnoreError`，`DelayedAutoCancellable` 等。
