# CombineX

![travis](https://img.shields.io/travis/luoxiu/CombineX.svg)
![release](https://img.shields.io/github/release-pre/luoxiu/combinex)
![install](https://img.shields.io/badge/install-spm%20%7C%20cocoapods%20%7C%20carthage-ff69b4)
![platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey)
![GitHub](https://img.shields.io/github/license/luoxiu/combinex?color=black)

CombineX 是 Apple's [Combine](https://developer.apple.com/documentation/combine) 的开源实现。它可以让你现在就用上 Combine 的 API，不需要 macOS 10.15 或者 iOS 13，不需要 Apple 平台。

## 状态

与 Combine beta 5 兼容。

每周一会发布一个新的 beta~

## 注意

本库仍在 beta 测试，所以，**还不可以把它用在生产项目中！**

🐱

## 试下

#### CocoaPods

#### CocoaPods

在你的 `Podfile` 里：

```ruby
pod 'CombineX.swift', :git => 'https://github.com/luoxiu/CombineX.git', :branch => 'master'
```

#### Swift Package Manager

在你的 `Package.swift` 里：

```swift
dependencies.append(
    .package(url: "https://github.com/luoxiu/CombineX", ._branchItem("master"))
)
```

## 相关

- [CombineX.Foundation](https://github.com/luoxiu/CombineX.Foundation)：提供所有 `Foundation` 扩展实现，基于 `CombineX`，比如 `URLSession`，`NotificationCenter`，`Timer` 等。
- [CombineX.Cocoa](https://github.com/luoxiu/CombineX.Foundation)：提供 `Cocoa` 扩展，基于 `CombineX`。
- [CombineX.Compatible](https://github.com/CombineXCommunity/CombineX.Compatible)：提供 `CombineX` 的 API Shims，帮助你解决可能会出现的迁移顾虑。


## 贡献

欢迎！！！`CombineX` 永远在寻找协作者！！！

现阶段，`CombineX` 最需要的是测试。你可以：

1. 添加更多的功能测试。
2. 确保 `Combine` 能通过它。
3. 如果 `CombineX` 不能通过，开一个 issue，或者直接修复它！

#### 流程

因为很多人还没有安装 macOS 10.15 beta，比如我，所以现在推荐的贡献流程是：

1. Fork 项目
2. 打开 `Specs/Specs.xcworkspace`，把你的工作放在 `CombineX/CombineX` 文件夹下。
3. 所有的测试都在 `CombineXTests/CombineXTests` 文件夹里，要确保你的测试能同时通过 `Specs` 和 `CombineX` 两个 Scheme。

## Combine 里的 bug

因为 `Combine` 都还在 beta，难免它自己都有 bug。如果遇到不合你理解的现象，请发 issue 一起讨论！或者留下一个 `// FIXME:` 标记。事实上，`CombineX` 里已经有很多 `FIXME` 标记了。

## 其它

#### 为什么要写这个库？

1. `Combine` 有较高的版本限制：macOS 10.15+，iOS 13+。也就是说如果你的 App 即使只需要往前兼容两个版本，也需要两三年后才能用得上它。
2. `Combine` 是闭源的，它与 `UIKit`，`MapKit` 等一样，随 xcode 的更新而更新。当你遇到 bug 时，你应该遇到过系统库的 bug 吧，调试很烦人，然而更烦人的是缓慢的官方反应，通常你只能等待下一次 xcode 的常规更新。
3. `Combine` 是 Apple 平台独占的，不能在 Linux 上运行。
