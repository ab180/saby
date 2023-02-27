//
//  PromiseRace.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    public static func race(
        on queue: DispatchQueue = .global(),
        _ promises: [Promise<Value, Failure>]
    ) -> Promise<Value, Failure> {
        let promiseReturn = Promise<Value, Failure>(queue: queue)
        
        for promise in promises {
            promise.subscribe(
                queue: queue,
                onResolved: { promiseReturn.resolve($0) },
                onRejected: { promiseReturn.reject($0) },
                onCanceled: { promiseReturn.cancel() }
            )
        }
        
        return promiseReturn
    }
}
