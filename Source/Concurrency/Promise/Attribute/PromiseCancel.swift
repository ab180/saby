//
//  PromiseCancel.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/03.
//

import Foundation

extension Promise {
    public static func cancel<AnyValue>(
        on queue: DispatchQueue = .global(),
        when promise: Promise<AnyValue>,
        block: () -> Promise<Value>
    ) -> Promise<Value> {
        let returnPromise = block()
        
        promise.subscribe(
            on: queue,
            onResolved: { _ in returnPromise.cancel() },
            onRejected: { _ in },
            onCanceled: {}
        )
        
        return returnPromise
    }
}
