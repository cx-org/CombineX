# CombineX

<img src="https://img.shields.io/travis/luoxiu/CombineX.svg">

CombineX is an open source implementation for Apple's [Combine](https://developer.apple.com/documentation/combine) specs.

## Notice

This library is still in the experimental stage, so, **DO NOT use it in production!**

In fact, Apple's Combine is also in beta, take it easy, 🐱.

## Try it out

### Swift Package Manager

In your `Package.swift`:

```swift
dependencies.append(
    .package(url: "https://github.com/luoxiu/CombineX", ._branchItem("master")
)
```

### Cocoapods

In your `Podfile`:

```ruby
target 'App' do 
    pod 'CombineX'
end
```

## Related

- [CombineX.Foundation](https://github.com/CombineXCommunity/CombineX.Foundation)
- [CombineX.Compatible](https://github.com/CombineXCommunity/CombineX.Compatible)

## Contribute

Welcome! CombineX is always looking for collaborators! 

Now, what `CombineX` need most are:

1. Add more functional tests.
2. Make sure `Combine` can pass them.
3. Check how `CombineX` is going.
4. If `CombineX` can not pass them, open an issue, or fix it!!!

### Bugs in Combine

Since `Combine` is still in beta, it is inevitable that it has bugs. If you find something strange, you can open an issue to discuss with us! or leave a `// FIXME:` annotation.

### Flow

Since some people may not have macOS 10.15 beta installed, the recommended contributing way is: 

1. Fork the project.
2. Open `Specs/Specs.xcworkspace`, make your changes under `Specs/CombineX` folder. 
3. All tests go `SpecsTests/CombineXTests` folder. Make sure both scheme `Specs` and scheme `CombineSpecs` pass the tests you wrote.


## Other

### Why write this?

1. `Combine` has a strict system version limit: macOS 10.15+, iOS 13+. This means that even if your app only needs to support two forward versions, you still need to wait for three years before you can use it.
2. `Combine` is closed source. It is the same as `UIKit`, `MapKit`, updating with the update of xcode. When you encounter a bug--you should have encountered a bug in the system library before--it's hard to debug. What's more annoying is the slow official response, usually you have to wait for the next regular update of xcode.
3. `Combine` is Apple platform only and doesn't support Linux.

## Goal

`CombineX` will try to provide:

1. ~100% identical behavior to the Apple Combine.
2. More `Combine` doesn't have but useful extensions. You can find them at [here] (https://github.com/CombineXCommunity).

When `CombineX` is officially released, all you need to do is:

```swift
#if USE_COMBINE
import Combine
#else
import CombineX
#endif
```

