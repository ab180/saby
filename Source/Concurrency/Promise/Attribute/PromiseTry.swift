//
//  PromiseRetry.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/03.
//

import Foundation

extension Promise where Failure == Error {
    public static func `try`(
        on queue: DispatchQueue = .global(),
        count: Int,
        _ block: @escaping () throws -> Promise<Value, Error>
    ) -> Promise<Value, Error> {
        var promise = Promise(on: queue) { try block() }
        
        for _ in 0..<max(count - 1, 0) {
            promise = promise.recover(on: queue) { _ in try block() }
        }
        
        return promise
    }
}
