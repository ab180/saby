//
//  WaitPromise.swift
//  SabyTestWait
//
//  Created by WOF on 2023/05/22.
//

import Foundation
import SabyConcurrency

public struct WaitPromise: Sendable {
    let timeout: DispatchTimeInterval
    
    public init(timeout: DispatchTimeInterval) {
        self.timeout = timeout
    }

    public func callAsFunction<Value: Sendable, Failure: Error & Sendable>(
        _ promise: Promise<Value, Failure>
    ) throws -> Value {
        let state = WaitPromiseState<Value, Failure>()
        promise.subscribe(
            onResolved: { state.complete(.resolved($0)) },
            onRejected: { state.complete(.rejected($0)) },
            onCanceled: {}
        )

        return try state.wait(timeout: timeout)
    }
}

private final class WaitPromiseState<
    Value: Sendable,
    Failure: Error & Sendable
>: @unchecked Sendable {
    private let lock = NSLock()
    private let semaphore = DispatchSemaphore(value: 0)
    private var result: WaitPromiseResult<Value, Failure>?

    func complete(_ result: WaitPromiseResult<Value, Failure>) {
        let completed = lock.withLock {
            guard self.result == nil else { return false }
            self.result = result
            return true
        }

        if completed {
            semaphore.signal()
        }
    }

    func wait(timeout: DispatchTimeInterval) throws -> Value {
        if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
            throw WaitError.timeout
        }

        switch lock.withLock({ result })! {
        case .resolved(let value):
            return value
        case .rejected(let error):
            throw error
        }
    }
}

private enum WaitPromiseResult<
    Value: Sendable,
    Failure: Error & Sendable
>: Sendable {
    case resolved(Value)
    case rejected(Failure)
}

enum WaitError: Error {
    case timeout
}
