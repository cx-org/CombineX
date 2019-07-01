# CombineX

<img src="https://img.shields.io/travis/luoxiu/CombineX.svg">

CombineX is an open source implementation for Apple's [Combine](https://developer.apple.com/documentation/combine) specs.

## Notice

This is an experimental project and currently under heavy development , so **DO NOT use it in production!**

## Why

1. Combine is closed source.
2. Combine is apple platform only.
3. Combine needs macOS 10.15, iOS 13.

## Goal

Making it no longer have the limitations of the platform and os version. 

CombineX will try to provide:

1. ~100% identical behavior to the Apple Combine.
2. Clear code and complete comments.
3. More useful extensions(in a separate target maybe).

When CombineX is officially released, all you need to do is:

```swift
#if CAN_USE_COMBINE
import Combine
#else
import CombineX
#endif
```

## Contribute

CombineX is always looking for collaborators! 

You can:

1. Implement new operators.
2. Add more compatibility tests to find behavior different from Apple Combine.
3. Fix bugs.
4. ...Anything you think can make CombineX better!

Since some people may not have macOS 10.15 beta installed, the recommended contributing way is: 

1. Fork the project.
2. Open `Specs/Specs.xcworkspace`, make your changes under `CombineX.xcodeproje`. 
3. All tests go `Specs/SpecsTests`. Make sure both scheme `Specs` and scheme `CombineSpecs` pass the test you wrote.

## State

### General

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`AnyCancellable`| done | done |   |
|`AnyPublisher`| done |   |   |
|`AnySubject`| done |   |   |
|`AnySubscriber`| done | done |   |
|`Cancellable`| done | no need |   |
|`CombineIdentifier`| done |   |   |
|`ConnectablePublisher`| done |   |   |
|`CustomCombineIdentifierConvertible`| done | no need |   |
|`Publisher`| done | no need |   |
|`Scheduler`| done | no need |   |
|`SchedulerTimeIntervalConvertible`| done | no need |   |
|`Subject`| done | no need |   |
|`Subscriber`| done | no need |   |
|`Subscription`| done | no need |   |

### Publishers

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`AllSatisfy`| done |   |   |
|`AssertNoFailure`| done |   |   |
|`Autoconnect`|   |   |   |
|`Breakpoint`|   |   |   |
|`Catch`|   |   |   |
|`CompactMap`| done |   | use `TryCompactMap` |
|`Concatenate`| done | basic |   |
|`Contains`| done |   |   |
|`ContainsWhere`| done |   |   |
|`Count`| done | basic |   |
|`Drop`| done |   |   |
|`DropWhile`| done |   |   |
|`Empty`| done | done |   |
|`Fail`| done |   | use `Optional` |
|`Filter`| done | done |   |
|`First`| done |   |   |
|`FirstWhere`| done |   |   |
|`FlatMap`| done | done |   |
|`Just`| done |   | use `Optional` |
|`Last`| done |   |   |
|`LastWhere`| done |   |   |
|`IgnoreOutput`| done |   |   |
|`Map`| done |   | use `TryCompactMap` |
|`MapError`| done | done |   |
|`MeasureInterval`| done | basic |   |
|`Merge`| done | basic |   |
|`Once`| done |   | use `Optional` |
|`Optional`| done | done |   |
|`Output`| done | basic |   |
|`Print`| done | done |   |
|`Publishers`| done | no need |   |
|`ReceiveOn`| done |   |   |
|`Reduce`| done |   |   |
|`RemoveDuplicates`| done |   |   |
|`Sequence`| done | done |   |
|`SetFailureType`| done |   |   |
|`SubscribeOn`|   |   |   |
|`TryAllSatisfy`| done |   |   |
|`TryCompactMap`| done | done |   |
|`TryContainsWhere`| done |   |   |
|`TryDropWhere`| done | basic |   |
|`TryFilter`| done |   |   |
|`TryFirst`| done |   |   |
|`TryLastWhere`| done |   |   |
|`TryMap`| done |   | use `TryCompactMap` |
|`TryReduce`| done |   |   |
|`TryRemoveDuplicates`| done |   |   |

### Schedulers

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`ImmediateScheduler`| done |   |   |

### Subjects

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`CurrentValueSubject`| done | done |   |
|`PassthroughSubject`| done | done |   |

### Subscribers

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`Assign`| done | done  |   |
|`Demand`| done | almost done |   |
|`Sink`| done | done |   |
|`Subscribers`| done  | no need |   |

### Subscriptions

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`empty`| done  |   |   |
|`Subscriptions`| done  | no need |   |
