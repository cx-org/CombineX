# CombineX

CombineX is an open source implementation for Apple's [Combine](https://developer.apple.com/documentation/combine) specs.

## Notice

This is an experimental project, **DO NOT use it in production!**

## Contribute

CombineX is always looking for collaborator! 

You can:

1. Implement new operators.
2. Add more compatibility tests to find different behavior between CombienX and Combine.
3. Fix bugs.
4. ...Anything you think can make CombineX better!

Since some people may not have macOS 10.15 beta installed, the recommended contributing way is: 

1. Fork the project.
2. Open `Specs/Specs.xcworkspace`, make your changes under `CombineX.xcodeproje`. 
3. All tests go `Specs/SpecsTests`. Make sure both scheme `Specs` and scheme `CombineSpecs` pass the test you wrote.

## Why

1. Combine is closed source.
2. Combine is apple platform only.
3. Combine needs macOS 10.15, iOS 13.

When CombineX is release, all you need to do is:

```swift
#if can_use_combine
import Combine
#else
import CombineX
#endif
```

## State

### General

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`AnyCancellable`| done |   |   |
|`AnyPublisher`| done |   |   |
|`AnySubject`| done |   |   |
|`Cancellable`| done |   |   |
|`CombineIdentifier`| done |   |   |
|`ConnectablePublisher`|   |   |   |
|`CustomCombineIdentifierConvertible`| done |   |   |
|`Publisher`| done |   |   |
|`Scheduler`| done |   |   |
|`SchedulerTimeIntervalConvertible`| done |   |   |
|`Subject`| done |   |   |
|`Subscriber`| done |   |   |
|`Subscription`| done |   |   |


### Publishers

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`Autoconnect`|   |   |   |
|`Empty`| done |   |   |
|`FlatMap`| wip |   |   |
|`Just`| done |   |   |
|`Map`| done |   |   |
|`MapError`| done |   |   |
|`Merge`|   |   | Waiting for `FlatMap` |
|`Once`| done |   |   |
|`Publishers`| done  |   |   |
|`Sequence`| done |   |   |
|`SubscribeOn`|   |   |   |
|`TryMap`| done |   |   |
|`assign`| done |   |   |
|`sink`| done |   |   |

### Schedulers

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`ImmediateScheduler`| done |   |   |

### Subjects

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`CurrentValueSubject`|   |   |   |
|`PassthroughSubject`| done |   |   |

### Subscribers

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`Assign`| done  |   |   |
|`Sink`| done  |   |   |
|`Subscribers`| done  |   |   |

### Subscriptions

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`Demand`| done  |   |   |
|`Subscriptions`| done  |   |   |
|`empty`| done  |   |   |
