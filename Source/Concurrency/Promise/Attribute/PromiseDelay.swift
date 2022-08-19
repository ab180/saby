//
//  PromiseDelay.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/08/19.
//

import Foundation

extension Promise where Value == Void {
    public static func delay(_ interval: DispatchTimeInterval) -> Promise<Void> {
        let (promise, resolve, _) = Promise.pending()
        
        promise.queue.asyncAfter(deadline: .now() + interval) {
            resolve(())
        }
        
        return promise
    }
}

extension Promise {
    @discardableResult
    public func delay(_ interval: DispatchTimeInterval) -> Promise<Value> {
        let promiseReturn = Promise<Value>(queue: queue)
        
        queue.asyncAfter(deadline: .now() + interval) {
            self.subscribe(subscriber: Subscriber(
                on: self.queue,
                onResolved: { promiseReturn.resolve($0) },
                onRejected: { promiseReturn.reject($0) }
            ))
        }
        
        return promiseReturn
    }
}
