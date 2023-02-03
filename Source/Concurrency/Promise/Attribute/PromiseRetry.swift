//
//  PromiseRetry.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/03.
//

import Foundation

extension Promise {
    public static func retry(
        on queue: DispatchQueue = .global(),
        _ count: UInt,
        _ block: @escaping () -> Promise<Value>
    ) -> Promise<Value> {
        var promise = block()
        
        for _ in 0..<count {
            promise = promise.recover { _ in block() }
        }
        
        return promise
    }
}
