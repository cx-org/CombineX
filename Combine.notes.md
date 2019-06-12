# state

```
enum State {
	case waiting
	case subscribing(Demand)
	case complete
	case cancelled
}
```

# Subscription

+ request demand 小于 0
    - 什么也不发送
    - 但会记住 demand
    - 如果继续 request demand 大于 0，会开始发送


+ Subscription 多次 `request(_:)`，如果这时是 subscribing 状态，就把 `demand` 加到 `subscribing` 上
+ `request(demand:)` 后就开始了 `receive(value:)`

## Assign

- flow
    - 自定义的 `AnySubscriber` 需要先发送 `subscription`，即 `sub.receive(subscriptions:)`。直接发 `value` 没有用
    - `receive(value:)` 总是返回 `.max(0)`
    - `receive(subscription:)` 总是请求 `unlimited`
    - 发送 `completion` 后，会调用 `subscription.cancel()`, 然后不再持有 `subscription`，即 `deinit`
    - 发送 `completion` 后，再发送新的 `value` 没有用了
    - 如果已经有 `subscription`，并且还没有 cancel，再发送 `subscription`, 新的会立即 `cancel/deinit`.
    - 如果已经有 `subscription`，并且已经被 cancel，再发送 `subscription` 会再次请求 `unlimited`，但再发送 value 已经没有效果了。（即，有状态，且只能结束一次。）


# Sink

- flow
    - 自定义的 `AnySubscriber` 需要先发送 `subscription`，即 `sub.receive(subscriptions:)`。直接发 `value` 没有用
    - `receive(value:)` 总是返回 `.max(0)`
    - `receive(subscription:)` 总是请求 `unlimited`
    - 发送 `completion` 后，会调用 `subscription.cancel()`, 然后不再持有 `subscription`，即 `deinit`
    - 发送 `completion` 后，再发送新的 `value` 仍然有用
    - 如果已经有 `subscription`，并且还没有 cancel，再发送 `subscription`, 新的会立即 `cancel/deinit`.
    - 如果已经有 `subscription`，并且已经被 cancel，再发送 `subscription` 会再次请求 `unlimited`，但再发送 value 仍然有用。（即，无状态，只要有事件就接收）


# SubscribeOn

- receiveSubscription 不会在 queue 上，value/completion 会在 queue 上