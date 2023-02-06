//
//  PromiseCancel.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/03.
//

import Foundation

extension Promise {
    @discardableResult
    public func cancel<AnyValue>(
        on queue: DispatchQueue? = nil,
        when promise: Promise<AnyValue>
    ) -> Promise<Value> {
        let queue = queue ?? self.queue
        
        promise.subscribe(
            on: queue,
            onResolved: { _ in self.cancel() },
            onRejected: { _ in },
            onCanceled: {}
        )

        return self
    }
}
