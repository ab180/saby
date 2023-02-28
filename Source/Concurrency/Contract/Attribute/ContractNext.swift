//
//  ContractNext.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/28.
//

import Foundation

extension Contract {
    public func next(
        on queue: DispatchQueue? = nil
    ) -> Promise<Value, Failure> {
        let queue = queue ?? self.queue
        
        let promise = Promise<Value, Failure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { value in promise.resolve(value) },
            onRejected: { error in promise.reject(error) },
            onCanceled: { promise.cancel() }
        )
        
        return promise
    }
}
