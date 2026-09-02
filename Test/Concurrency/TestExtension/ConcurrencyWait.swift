//
//  ConcurrencyWait.swift
//  SabyAppleStorageTest
//
//  Created by WOF on 2023/05/25.
//

import Foundation
import SabyConcurrency

extension Contract {
    @discardableResult
    func testValue(
        until: @escaping @Sendable (Value) -> Bool = { _ in true },
        _ block: () -> Void
    ) async throws -> Value {
        let result = LockedBox<Value?>(nil)
        let completed = AsyncLatch()
        subscribe(
            onResolved: { value in
                guard until(value) else { return }
                let isFirst = result.withValue {
                    guard $0 == nil else { return false }
                    $0 = value
                    return true
                }
                if isFirst { completed.signal() }
            },
            onRejected: { _ in completed.signal() },
            onCanceled: { completed.signal() }
        )
        block()
        guard await completed.wait(timeout: .seconds(3)), let value = result.value else {
            throw CancellationError()
        }
        return value
    }
}
