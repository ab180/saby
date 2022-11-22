//
//  PromiseRace.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    public static func race<Result>(
        on queue: DispatchQueue = .global(),
        _ promises: [Promise<Result>]
    ) -> Promise<Result> where Value == Void
    {
        let promiseReturn = Promise<Result>(queue: queue)
        
        for promise in promises {
            promise.subscribe(subscriber: Promise<Result>.Subscriber(
                on: queue,
                onResolved: { promiseReturn.resolve($0) },
                onRejected: { promiseReturn.reject($0) }
            ))
        }
        
        return promiseReturn
    }
}
