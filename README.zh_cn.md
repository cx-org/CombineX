# CombineX

![travis](https://img.shields.io/travis/cxswift/CombineX.svg)
![release](https://img.shields.io/github/release-pre/cxswift/combinex)
![install](https://img.shields.io/badge/install-spm%20%7C%20cocoapods%20%7C%20carthage-ff69b4)
![platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey)
![license](https://img.shields.io/github/license/cxswift/combinex?color=black)

CombineX 是 Apple's [Combine](https://developer.apple.com/documentation/combine) 的开源实现。它可以让你摆脱平台与版本的限制，现在就用上 Combine 的 API。

## 注意

本库仍在 beta 测试，所以，**还不可以把它用在生产项目中！**

🐱

## 状态

与 Combine beta 6 兼容。

## 什么是 Combine

Combine 是 Apple 在 WWDC 2019 上推出的响应式框架，它「参考」了 [ReactiveX](http://reactivex.io/) 的接口设计，为 Swift 异步编程提供了钦定实现。在可预见的将来，它一定会成为 Swift 编程的基石。

## 什么是 CombineX

CombineX 是 Combine 的开源实现。除了有着与 Combine 一致的 API 和行为，它还有以下优势：

### 1. 版本与平台

`Combine` 有极高的版本限制：macOS 10.15+，iOS 13+。也就是说，即使你的 App 只需要向前兼容两个版本，也需要两三年后才能用得上它。`Combine` 是 Apple 平台独占的，不支持 Linux。

`CombineX` 帮你摆脱了这些限制，它支持 macOS 10.12+，iOS 10+，支持 Linux。通过 `CombineX`，你可以在更多的平台和版本上使用相同的代码。

### 2. 开源

`Combine` 是闭源的，它与 `UIKit`，`MapKit` 等一样，随着 xcode 的更新而更新。当你遇到 bug 时，「你应该遇到过系统库的 bug 吧」，调试是非常烦人的，但更烦人的是缓慢的官方反应，通常你除了等待下一次 xcode 的常规更新以外无能为力。

### 3. 扩展

`CombineX` 贴心地为你提供了诸多相关扩展，包括但不限于：

- [CombineX.Foundation](https://github.com/luoxiu/CombineX.Foundation)：提供所有 `Foundation` 的扩展实现，基于 `CombineX`。比如 `URLSession`，`NotificationCenter`，`Timer`，`DispatchQueue+Scheduler`，`RunLoop+Scheduler`等。
- [CombineX.Cocoa](https://github.com/luoxiu/CombineX.Cocoa)：提供 `Cocoa` 的扩展实现，基于 `CombineX`。比如 `KVOPublisher`，`MethodInterceptionPublisher`，`UIKit+CX` 等。
- [CombineX.Compatible](https://github.com/CombineXCommunity/CombineX.Compatible)：提供 `CombineX` 的 API Shims，帮助你解决可能会出现的迁移顾虑。通过该库，你可以在任何时候轻松地被底层库从 `CombineX` 切换到 `Combine`。

#### 3.1 CombineX.Cocoa 实例

<p align="center">
<img src="demo.1.gif" height="500">
<img src="demo.2.gif" height="500">
</p>

## 安装

### Swift Package Manager

```swift
dependencies.append(
    .package(url: "https://github.com/cxswift/CombineX", .branch("master"))
)
```

### CocoaPods

```ruby
pod 'CombineX.swift', :git => 'https://github.com/cxswift/CombineX.git', :branch => 'master'
```

### Carthage

```carthage
github "cxswift/CombineX" "master"
```

## 贡献

**欢迎！`CombineX` 非常需要协作者！！！**

现阶段，`CombineX` 最需要的是测试。你可以：

1. 添加更多的功能测试。
2. 确保 `Specs` 能通过它。
3. 如果 `CombineX` 不能通过，那说明你发现了一个 `CombineX` 的 bug，你可以开一个 issue，或者直接修复它！

### 流程

因为很多人还没有安装 macOS 10.15 beta，比如我，所以现在推荐的贡献流程是：

1. Fork 项目
2. 打开 `Specs/Specs.xcworkspace`，把你的修改放在 `CombineX/CombineX` 文件夹下。
3. 所有的测试都在 `CombineXTests/CombineXTests` 文件夹下，要确保你的测试能同时通过 `Specs` 和 `CombineX` 两个 Scheme 哦。

## Combine 里的 bug

因为 `Combine` 都还在 beta，难免它自己还有 bug。如果遇到你理解不了的现象，开一个 issue 和我们一起讨论吧！
