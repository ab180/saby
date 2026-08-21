//
//  PromiseTry.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/03.
//

import Foundation

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func `try`<Result: Sendable>(
        on queue: DispatchQueue = .global(),
        count: Int,
        _ block: @escaping @Sendable () throws -> Promise<Result, Error>
    ) -> Promise<Result, Error> {
        let attempt: @Sendable () -> Promise<Result, Error> = {
            Promise<Result, Error>(on: queue) { resolve, reject, cancel, _ in
                try block().subscribe(
                    on: queue,
                    onResolved: resolve,
                    onRejected: reject,
                    onCanceled: cancel
                )
            }
        }

        var promise = attempt()
        
        for _ in 0..<max(count - 1, 0) {
            promise = promise.recover(on: queue) { _ in attempt() }
        }
        
        return promise
    }
}
