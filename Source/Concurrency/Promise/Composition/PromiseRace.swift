//
//  PromiseRace.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func race<Result, ResultFailure>(
        on queue: DispatchQueue = .global(),
        _ promises: [Promise<Result, ResultFailure>]
    ) -> Promise<Result, ResultFailure> {
        let promiseReturn = Promise<Result, ResultFailure>(queue: queue)
        
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
