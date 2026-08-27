//
//  PromiseValue.swift
//  SabyConcurrency
//

import Foundation

extension Promise {
    public func value(
        cancelOnTaskCancellation: Bool = false
    ) async throws -> Value {
        let waiter = PromiseValueWaiter<Value>()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard waiter.install(continuation) else { return }

                subscribe(
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

private final class PromiseValueWaiter<Value: Sendable>: @unchecked Sendable {
    typealias Continuation = CheckedContinuation<Value, Error>

    private let lock = NSLock()
    private var continuation: Continuation?
    private var result: Result<Value, Error>?

    func install(_ continuation: Continuation) -> Bool {
        let result: Result<Value, Error>? = lock.withLock {
            guard let result = self.result else {
                self.continuation = continuation
                return nil
            }
            return result
        }

        guard let result else { return true }
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
        let continuation: Continuation? = lock.withLock {
            guard self.result == nil else { return nil }

            self.result = result
            defer { self.continuation = nil }
            return self.continuation
        }

        continuation?.resume(with: result)
    }
}
