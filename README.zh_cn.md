# CombineX

[![travis](https://img.shields.io/travis/cx-org/CombineX.svg)](https://travis-ci.org/cx-org/CombineX)
[![release](https://img.shields.io/github/release-pre/cx-org/combinex)](https://github.com/cx-org/CombineX/releases)
![install](https://img.shields.io/badge/install-spm%20%7C%20cocoapods%20%7C%20carthage-ff69b4)
![platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey)
![license](https://img.shields.io/github/license/cx-org/combinex?color=black)
[![dicord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/9vzqgZx)

`CombineX` 是 Apple's [Combine](https://developer.apple.com/documentation/combine) 的开源实现。它的 API 与 `Combine` 一致，它可以作为 `Combine` 在 iOS 8、macOS 10.10 与 Linux 上的 polyfill，帮你摆脱系统版本与平台的限制。

## 注意

本库还在 beta，所以，**还不可以把它用在生产中！**

🐱

## 支持

- iOS 8+ / macOS 10.10+ / tvOS 9+ / watchOS 2+
- Linux - Ubuntu 16.04

## 什么是 Combine

`Combine` 是 Apple 在 WWDC 2019 上推出的响应式框架，它「参考」了 [ReactiveX](http://reactivex.io/) 的接口设计，为 Swift 异步编程提供了官方实现。在可预见的将来，它一定会成为 Swift 编程的基石。

## 什么是 CombineX

`CombineX` 是 `Combine` 的开源实现。除了拥有与 `Combine` 一致的 API 外，它还有以下优势：

### 1. 系统版本与平台

- `Combine` 有着极高的系统版本限制：macOS 10.15+，iOS 13+。这意味着，即使你的 App 只需要向前兼容三个版本，也需要三四年后才能用上 `Combine`。
- `Combine` 是 Apple 平台独占的，所以你无法在 apple 和 linux 上共享代码库。

`CombineX` 可以帮你摆脱这些限制，它支持 macOS 10.10+、iOS 8+ 与 Linux。

### 2. 开源

`Combine` 是闭源的，它与 `UIKit`，`MapKit` 等一样，随着 Xcode 更新而更新。当你遇到 bug 时，「你应该遇到过系统库的 bug 吧」，调试是非常烦人的，但更烦人的是缓慢的官方反应，通常你除了等待下一次 Xcode 的常规更新以外无能为力。

而 `CombineX` 是完全开源的，除了可以逐行调试以外，你还能得到更快的社区响应！

### 3. 扩展

`CombineX` 提供了诸多相关扩展，包括但不限于：

- [CXFoundation](https://github.com/cx-org/CXFoundation)：提供 `Foundation` 扩展的实现，基于 `CombineX`。比如 `URLSession`，`NotificationCenter`，`Timer`，`DispatchQueue/RunLoop/OperationQueue+Scheduler`，`JSON/Plist+Coder` 等。
- [CXCompatible](https://github.com/cx-org/CXCompatible)：提供 `CombineX` 的 API Shims，解决可能会出现的迁移顾虑。通过该库，你可以在任何时候轻松地把所有依赖于 `CombineX` 的代码切换到 `Combine`。

***

有了 `CombineX`，你还可以自由地开发 `Combine` 的相关框架，不用担心系统版本和平台的限制，比如：

- [CXCocoa](https://github.com/cx-org/CXCocoa)：提供 `Cocoa` 的 `Combine` 扩展。比如 `KVO+Publisher`，`Method Interception`，`UIBinding`，`Delegate Proxy` 等。默认基于 `CombineX`，你可以自由地切换到 `Combine`。
- [CXExtensions](https://github.com/cx-org/CXExtensions)：提供一系列有用的 Combine 扩展，比如：`IgnoreError`，`DelayedAutoCancellable` 等。默认基于 `CombineX`，你可以自由地切换到 `Combine`。

<p align="center">
<img src="demo.1.gif" height="500">
<img src="demo.2.gif" height="500">
</p>

## 参与 (｡◕‿◕｡✿)

想参与进来吗？太好了！！！**`CombineX` 现在非常需要以下帮助**！🆘🆘🆘

#### 📈 项目管理

我们需要项目管理方面的帮助！

`CombineX` 是我第一次组织如此大的开源项目，它起源于一时兴起，动力来自于我对 Swift 和开源的热情。我喜欢写代码，实现东西，但现在，我花在组织与部署上的时间比写代码还要多。`CombineX` 已经不仅仅是 `CombineX` 了，它现在除了主仓库外已经有了四个关联仓库，同时，我还有非常多的点子等待验证。所以我们非常需要有人来帮助管理整个项目，包括 [cx-org](https://github.com/cx-org) 与 [cx-community](https://github.com/cx-community)。

#### 🔨 寻找 bug

你可以帮助 `CombineX` 寻找 bug。

`CombineX` 使用测试保证它与 `Combine` 的行为一致。但目前，测试数量远远不够，还有很多边缘用例没考虑到。你可以添加更多的测试来提高 `CombineX` 的正确率，首先，确保 `Specs` scheme 可以通过你的测试，如果 `CombineX` scheme 没有通过，就说明你发现了一个 `CombineX` 的 bug！你可以通过 issue 反馈给我们，或者——直接修复它！

#### 💯 改进实现

`CombineX` 最初是我的业余项目，由于时间原因，很多可以做得更好的地方目前只保证了功能的实现，你可以改进它们，无论是性能上的，安全上的，还是可读性上的。接下来，我也会专注于这部分。

#### 💬 参与 issue 与 pr 里的讨论

你还可以通过参与 issue 与 pr 里的讨论来参与，回答别人的问题，review 代码。

参与不必一定与代码有关，还有更简单的，那就是 star！然后告诉你的朋友们！

### 贡献流程

因为很多人还没有安装 macOS 10.15 beta，比如我，所以现在推荐的贡献流程是：

1. Fork 项目
2. 打开 `Specs/Specs.xcworkspace`，在 `CombineX/CombineX` 文件夹下进行你的修改。
3. 所有的测试都在 `CombineXTests/CombineXTests` 文件夹下，要确保你的测试能同时通过 `Specs` 和 `CombineX` 两个 Scheme 哦。

⚠️⚠️⚠️ 不要打开 `CombineX.xcodeproj` 进行编辑，它只为 carthage 存在。

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

