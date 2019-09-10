# CombineX

[![travis](https://img.shields.io/travis/cx-org/CombineX.svg)](https://travis-ci.org/cx-org/CombineX)
[![release](https://img.shields.io/github/release-pre/cx-org/combinex)](https://github.com/cx-org/CombineX/releases)
![install](https://img.shields.io/badge/install-spm%20%7C%20cocoapods%20%7C%20carthage-ff69b4)
![platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey)
![license](https://img.shields.io/github/license/cx-org/combinex?color=black)
[![dicord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/cresT3X)

`CombineX` 是 Apple's [Combine](https://developer.apple.com/documentation/combine) 的开源实现，它提供了与 `Combine` 完全一致的 API，让你摆脱版本与平台的限制。

## 注意

本库仍在 beta，所以，**还不可以把它用在生产项目中！**

🐱

## 贡献 (｡◕‿◕｡✿)

想参与进来吗？太酷了！**`CombineX` 现在非常需要你的帮助！**

你可以：

- 寻找 bug
- 改进实现
- 参与 issue 里的讨论
- 审核 pull request

或者更简单点？star！然后告诉你的朋友们！

### 测试

`CombineX` 最需要的是测试，用更多的测试用例来保证它与 `Combine` 的行为一致性，添加测试的规则是：

1. 添加更多的功能测试。
2. 确保 `Specs` 能通过它。
3. 如果 `CombineX` 不能通过，那说明你发现了一个 `CombineX` 的 bug，你可以开一个 issue，或者直接修复它！

### 详细流程

因为很多人还没有安装 macOS 10.15 beta，比如我，所以现在推荐的贡献方式是：

1. Fork 项目
2. 打开 `Specs/Specs.xcworkspace`，在 `CombineX/CombineX` 文件夹下进行你的修改。
3. 所有的测试都在 `CombineXTests/CombineXTests` 文件夹下，要确保你的测试能同时通过 `Specs` 和 `CombineX` 两个 Scheme 哦。

## 什么是 Combine

`Combine` 是 Apple 在 WWDC 2019 上推出的响应式框架，它「参考」了 [ReactiveX](http://reactivex.io/) 的接口设计，为 Swift 异步编程提供了钦定实现。在可预见的将来，它一定会成为 Swift 编程的基石。

## 什么是 CombineX

`CombineX` 是 `Combine` 的开源实现。除了有着与 `Combine` 一致的 API，它还拥有有以下优势：

### 1. 版本与平台

`Combine` 有着极高的版本限制：macOS 10.15+，iOS 13+。这意味着，即使你的 App 只需要向前兼容两个版本，也需要两三年后才能使用 `Combine`。而且，`Combine` 是 Apple 平台独占的，不支持 Linux，所以你无法在 apple 和 linux 上共享一份代码。

`CombineX` 帮你摆脱了这些限制，它支持 macOS 10.10+，iOS 8+，支持 Linux。通过 `CombineX`，你可以在更多的平台和版本上使用相同的代码。

### 2. 开源

`Combine` 是闭源的，它与 `UIKit`，`MapKit` 等一样，随着 Xcode 的更新而更新。当你遇到 bug 时，「你应该遇到过系统库的 bug 吧」，调试是非常烦人的，但更烦人的是缓慢的官方反应，通常你除了等待下一次 Xcode 的常规更新以外无能为力。

而 `CombineX` 是完全开源的，除了可以逐行调试以外，你还能得到更快的社区响应！

### 3. 扩展

`CombineX` 贴心地为你提供了诸多相关扩展，包括但不限于：

- [CXFoundation](https://github.com/cx-org/CXFoundation)：提供所有 `Foundation` 扩展的实现，基于 `CombineX`。比如 `URLSession`，`NotificationCenter`，`Timer`，`DispatchQueue+Scheduler`，`RunLoop+Scheduler`等。
- [CXCompatible](https://github.com/cx-org/CXCompatible)：提供 `CombineX` 的 API Shims，帮助你解决可能会出现的迁移顾虑。通过该库，你可以在任何时候轻松地把依赖从 `CombineX` 切换到 `Combine`。

有了 `CombineX`，你可以自由地开发 `Combine` 的相关框架，不用担心版本和平台的限制。

- [CXCocoa](https://github.com/cx-org/CXCocoa)：提供 `Cocoa` 的扩展实现。比如 `KVOPublisher`，`MethodInterceptionPublisher`，`UIBinding` 等。
- [CXExtensions](https://github.com/cx-org/CXExtensions)：提供一系列有用的 Combine 扩展，比如：`DiscardError`，`DelayedAutoCancellable` 等。

<p align="center">
<img src="demo.1.gif" height="500">
<img src="demo.2.gif" height="500">
</p>

## 安装

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

## Combine 里的 bug

因为 `Combine` 都还在 beta，难免它自己还有 bug。如果遇到你理解不了的现象，开一个 issue 和我们一起讨论吧！
