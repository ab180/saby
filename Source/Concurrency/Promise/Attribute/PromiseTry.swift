//
//  PromiseTry.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/03.
//

import Foundation

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func `try`<Result>(
        on queue: DispatchQueue = .global(),
        count: Int,
        _ block: @escaping () throws -> Promise<Result, Error>
    ) -> Promise<Result, Error> {
        var promise = Promise.async(on: queue) { try block() }
        
        for _ in 0..<max(count - 1, 0) {
            promise = promise.recover(on: queue) { _ in try block() }
        }
        
        return promise
    }
}
