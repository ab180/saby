//
//  PromiseTimeout.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise where Value == Void {
    public static func timeout(
        on queue: DispatchQueue = .global(),
        _ interval: DispatchTimeInterval
    ) -> Promise<Void> {
        let (promise, _, reject) = Promise.pending(on: queue)
        
        queue.asyncAfter(deadline: .now() + interval) {
            reject(InternalError.timeout)
        }
        
        return promise
    }
}

extension Promise {
    @discardableResult
    public func timeout(
        on queue: DispatchQueue? = nil,
        _ interval: DispatchTimeInterval
    ) -> Promise<Value> {
        let queue = queue ?? self.queue
        
        queue.asyncAfter(deadline: .now() + interval) {
            self.reject(InternalError.timeout)
        }
        
        return self
    }
}
