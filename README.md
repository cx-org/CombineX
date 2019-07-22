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
#if USE_COMBINE
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
2. Open `Specs/Specs.xcworkspace`, make your changes under `Specs/CombineX` folder. 
3. All tests go `SpecsTests/CombineXTests` folder. Make sure both scheme `Specs` and scheme `CombineSpecs` pass the tests you wrote.

## State

### General

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`AnyCancellable`| done | done |   |
|`AnyPublisher`| done |   |   |
|`AnySubject`| done |   |   |
|`AnySubscriber`| done | done |   |
|`Cancellable`| done | no need |   |
|`CombineIdentifier`| done | done |   |
|`ConnectablePublisher`|   |   |   |
|`CustomCombineIdentifierConvertible`| done | no need |   |
|`Published`|   |   |   |
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
|`AssertNoFailure`| done | done |   |
|`Autoconnect`|   |   |   |
|`Breakpoint`| done |   |   |
|`Buffer`|   |   |   |
|`Catch`| done |   |   |
|`Collect`| done |   |   |
|`CollectByCount`| done | done |   |
|`CollectByTime`|   |   |   |
|`CombineLatest`| done | basic | b |
|`CompactMap`| done |   |   |
|`Comparison`| done |   |   |
|`Concatenate`| done | done |   |
|`Contains`| done |   |   |
|`ContainsWhere`| done |   |   |
|`Count`| done | basic |   |
|`Debounce`|   |   |   |
|`Delay`|   |   |   |
|`Drop`| done |   |   |
|`Decode`| done |   |   |
|`DropUntilOutput`| done | done |   |
|`DropWhile`| done |   |   |
|`Empty`| done | done |   |
|`Encode`| done |   |   |
|`Fail`| done |   |   |
|`Filter`| done |   |   |
|`First`| done |   |   |
|`FirstWhere`| done |   |   |
|`FlatMap`| done | done |   |
|`Future`| done | basic | b |
|`HandleEvents`| done |   | wip |
|`IgnoreOutput`| done |   |   |
|`Just`| done | done |   |
|`Last`| done |   |   |
|`LastWhere`| done |   |   |
|`MakeConnectable`|   |   |   |
|`Map`| done |   |   |
|`MapError`| done | done |   |
|`MapKeyPath`| done |   |   |
|`MeasureInterval`| done | done |   |
|`Merge`| done | done |   |
|`Multicast`|   |   |   |
|`Optional`| done | done |   |
|`Output`| done | done |   |
|`PrefixUntilOutput`| done | done |   |
|`PrefixWhile`| done |   |   |
|`Print`| done | done |   |
|`Publishers`| done | no need |   |
|`ReceiveOn`| done | basic | b |
|`Reduce`| done |   |   |
|`RemoveDuplicates`| done | done |   |
|`ReplaceEmpty`| done | done |   |
|`ReplaceError`| done | done |   |
|`Result`| done | done |   |
|`Retry`|   |   |   |
|`Scan`| done |   |   |
|`Sequence`| done | done |   |
|`SetFailureType`| done |   |   |
|`Share`|   |   |   |
|`SubscribeOn`| done | basic | b |
|`SwitchToLatest`| done | basic | b |
|`Throttle`|   |   |   |
|`Timeout`|   |   |   |
|`TryAllSatisfy`| done | done |   |
|`TryCatch`| done | done |   |
|`TryCombineLatest`| done |   | b |
|`TryCompactMap`| done | done |   |
|`TryComparison`| done |   |   |
|`TryContainsWhere`| done |   |   |
|`TryDropWhere`| done | done |   |
|`TryFilter`| done |   |   |
|`TryFirstWhere`| done |   |   |
|`TryLastWhere`| done |   |   |
|`TryMap`| done |   |   |
|`TryPrefixWhile`| done | done |   |
|`TryReduce`| done | done |   |
|`TryRemoveDuplicates`| done | done |   |
|`TryScan`| done | done |   |
|`Zip`| done | basic | b |

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
|`Demand`| done | done |   |
|`Sink`| done | done |   |
|`Subscribers`| done | no need |   |

### Subscriptions

| API | Status | Test | Notes |
|:--|:--|:--|:--|
|`empty`| done |   |   |
|`Subscriptions`| done  | no need |   |
