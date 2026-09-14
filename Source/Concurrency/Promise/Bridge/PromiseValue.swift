//
//  PromiseValue.swift
//  SabyConcurrency
//
//  Created by mjgu on 2026/09/14.
//

import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Promise where Value: Sendable {
    /// Awaits resolution, rejection, or cancellation of this promise.
    /// Canceling the awaiting task throws `CancellationError`. The shared promise
    /// keeps running unless `cancelOnTaskCancellation` is explicitly enabled.
    public func value(
        cancelOnTaskCancellation: Bool = false
    ) async throws -> Value {
        let waiter = PromiseValueWaiter<Value>()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard waiter.install(continuation) else { return }

                subscribe(
                    on: .global(),
                    onResolved: { waiter.resume(returning: $0) },
                    onRejected: { waiter.resume(throwing: $0) },
                    onCanceled: { waiter.resume(throwing: CancellationError()) }
                )
            }
        } onCancel: {
            waiter.resume(throwing: CancellationError())
            if cancelOnTaskCancellation {
                cancel()
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private final class PromiseValueWaiter<Value: Sendable>: @unchecked Sendable {
    typealias Continuation = CheckedContinuation<Value, Error>

    private let lock = NSLock()
    private var continuation: Continuation?
    private var result: Result<Value, Error>?

    private func withLock<Result>(_ body: () -> Result) -> Result {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }

    func install(_ continuation: Continuation) -> Bool {
        let result: Result<Value, Error>? = withLock {
            guard let result = self.result else {
                self.continuation = continuation
                return nil
            }
            return result
        }

        guard let result = result else { return true }
        continuation.resume(with: result)
        return false
    }

    func resume(returning value: Value) {
        resume(with: .success(value))
    }

    func resume(throwing error: Error) {
        resume(with: .failure(error))
    }

    private func resume(with result: Result<Value, Error>) {
        let continuation: Continuation? = withLock {
            guard self.result == nil else { return nil }

            self.result = result
            defer { self.continuation = nil }
            return self.continuation
        }

        continuation?.resume(with: result)
    }
}
