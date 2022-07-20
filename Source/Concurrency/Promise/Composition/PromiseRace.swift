//
//  PromiseRace.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    public static func race<Result>(
        on queue: DispatchQueue = Setting.defaultQueue,
        @RaceBuilder builder: () -> [Promise<Result>]
    ) -> Promise<Result> where Value == Void
    {
        let promiseReturn = Promise<Result>(on: queue)
        
        let promises = builder()
        for promise in promises {
            promise.subscribe(subscriber: Promise<Result>.Subscriber(
                on: queue,
                onResolved: { promiseReturn.resolve($0) },
                onRejected: { promiseReturn.reject($0) }
            ))
        }
        
        return promiseReturn
    }
    
    @resultBuilder
    public struct RaceBuilder {
        public static func buildBlock<Result>(_ promises: Promise<Result>...) -> [Promise<Result>]
        {
            promises
        }
    }
}
