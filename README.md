# CombineX

CombineX is an open source impletation for Apple's [Combine](https://developer.apple.com/documentation/combine) specs.

## Why

1. Combine is closed source.
2. Combine is apple platform only.
3. Combine needs macOS 10.15, iOS 13.
4. Study Reactive.

## Notice

This is an experimental project, so **DO NOT use it in production!**

## Contribute

Always welcome!

1. Fork the project.
2. Add your changes.
3. All tests go `Specs/SpecsTests`. Make sure both scheme `Specs` and scheme `CombineSpecs` pass the test you wrote.

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