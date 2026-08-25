//
//  WaitContract.swift
//  SabyTestWait
//
//  Created by WOF on 2023/05/22.
//

import Foundation
import SabyConcurrency

public struct WaitContract: Sendable {
    let timeout: DispatchTimeInterval
    
    public init(timeout: DispatchTimeInterval) {
        self.timeout = timeout
    }

    public func callAsFunction<Value: Sendable, Failure: Error & Sendable>(
        _ contract: Contract<Value, Failure>,
        until: @escaping (Value) -> Bool = { _ in true },
        _ block: () throws -> Void
    ) throws -> Value {
        let state = WaitContractState<Value, Failure>(until: until)

        contract.subscribe(
            onResolved: { state.resolve($0) },
            onRejected: { state.reject($0) },
            onCanceled: {}
        )
        try block()

        return try state.wait(timeout: timeout)
    }
}

private final class WaitContractState<
    Value: Sendable,
    Failure: Error & Sendable
>: @unchecked Sendable {
    private let lock = NSLock()
    private let semaphore = DispatchSemaphore(value: 0)
    private let until: (Value) -> Bool
    private var result: Result<Value, Failure>?

    init(until: @escaping (Value) -> Bool) {
        self.until = until
    }

    func resolve(_ value: Value) {
        complete(.success(value), where: until(value))
    }

    func reject(_ error: Failure) {
        complete(.failure(error), where: true)
    }

    func wait(timeout: DispatchTimeInterval) throws -> Value {
        if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
            throw WaitError.timeout
        }

        return try lock.withLock { try result!.get() }
    }

    private func complete(
        _ result: Result<Value, Failure>,
        where condition: Bool
    ) {
        let completed = lock.withLock {
            guard condition, self.result == nil else { return false }
            self.result = result
            return true
        }

        if completed {
            semaphore.signal()
        }
    }
}
