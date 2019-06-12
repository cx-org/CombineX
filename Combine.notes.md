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


+ Subscription 多次 `request(_:)`

    - 把 `demand` 加到 `subscribing` 上

+ SubscribeOn

    - 一次把已有的 value -> completion 都放入 scheduler

```swift
let pub = Publishers.Sequence<[Int], Never>(sequence: [1, 2])

let anySub = AnySubscriber<Int, Never>(receiveSubscription: { (s) in
		print
	}, receiveValue: { v in
		print("receiveValue is on queue", DispatchQueue.isOn(queue))
		print("receive value", v)
		    
		queue.async {		// 1 -> 2 -> completion -> "async queue"
		    print("async queue")
		}
		return .max(0)
	} , receiveCompletion: { completion in
		print("receiveCompletion is on queue", DispatchQueue.isOn(queue))
		print("receive completion", completion)
	})
```

## Assign

- flow
    - 自定义的 `AnySubscriber` 需要先发送 `subscription`，即 `sub.receive(subscriptions:)`。直接发 `value` 没有用
    - `receive(value:)` 总是返回 `.max(0)`
    - `receive(subscription:)` 总是请求 `unlimited`
    - 发送 `completion` 后，会调用 `subscription.cancel()`
    - 发送 `completion` 后，再发送新的 `value` 没有用了
    - 如果已经有 `subscription`，并且还没有 cancel，再发送 `subscription`, 新的会立即 `cancel/deinit`.
    - 如果已经有 `subscription`，并且已经被 cancel，再发送 `subscription` 会再次请求 `unlimited`，但再发送 value 已经没有效果了。


# Sink & Assign

- 自定义的 AnySubscriber 需要先发送 subscription，即 `sub.receive(subscriptions:)`。

- Cancel a sink/assign
    - 没有任何作用

- sink 收到 completion 后继续收到 value
    - 继续更新


- assign 收到 completion 后继续收到 value
    - 不会再被更新

# SubscribeOn

- receiveSubscription 不会在 queue 上，value/completion 会在 queue 上