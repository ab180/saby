//
//  PromiseTimeout.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {
    @discardableResult
    public func timeout(_ interval: DispatchTimeInterval) -> Promise<Value> {
        queue.asyncAfter(deadline: .now() + interval) {
            self.reject(InternalError.timeout)
        }
        
        return self
    }
}
