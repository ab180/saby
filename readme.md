# saby

Airbridge SDK core library for swift.

- Concurrency
    - Atomic: Access to single value without data race
    - Contract: Handle multiple values asynchronously
    - Promise: Handle single value asynchronously
- Expect: Assert instance status
- JSON: JSON definition
- Mock: Emulate behavior of instance that make side effect
- Network: Communicate with server using Promise
- Numeric: Numeric extension
- Safe: Handle Any value safely
- Time: Time definition

### Swift Concurrency bridges

On iOS 13, macOS 10.15, tvOS 13, and watchOS 6 or later:

```swift
let value = try await promise.value()
let next = promise.then { value in await transform(value) }
let scope = PromiseTaskScope(cancelWhen: .deinit)
let request = scope.promise { try await fetchValue() }

for await event in contract.stream {
    // Result.success and Result.failure are both events; cancellation ends the stream.
}
```

- `value()` throws `CancellationError` when the awaiting task or source promise is
  canceled. Task cancellation preserves the source promise by default; pass
  `cancelOnTaskCancellation: true` to cancel it as well.
- Async `then` runs its operation in a Swift task. `on:` selects the callback queue,
  not the executor of the async operation. `Contract.then(schedule: .sync)` waits
  for each async operation to finish before starting the next one.
- `PromiseTaskScope` exposes throwing operations as `Promise<Value, Error>` and
  nonthrowing operations as `Promise<Value, Never>`. `.deinit` cancels outstanding
  tasks when the scope is released; the default `.none` lets them finish.
- `Contract.stream` buffers events without a limit and preserves their order.
  Rejection emits a failure without ending the stream. For `Failure == Never`, use
  `let stream: AsyncStream<Value> = contract.stream` to select the value-only form.
  Canceling an iterator does not cancel the shared source contract.

These bridges retain the existing Swift 5 language mode and GCD-based internals;
this change does not make the package fully Swift 6 strict-concurrency compliant.
