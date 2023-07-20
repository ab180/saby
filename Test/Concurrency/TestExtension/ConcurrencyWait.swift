//
//  ConcurrencyWait.swift
//  SabyAppleStorageTest
//
//  Created by WOF on 2023/05/25.
//

import Foundation
import SabyConcurrency
import SabyTestWait

let waitPromise = WaitPromise(timeout: .seconds(3))
let waitContract = WaitContract(timeout: .seconds(3))

extension Promise {
    @discardableResult
    func wait() throws -> Value {
        try waitPromise(self)
    }
}

extension Contract {
    @discardableResult
    func wait(
        until: @escaping (Value) -> Bool = { _ in true },
        _ block: () -> Void
    ) throws -> Value {
        try waitContract(self, until: until, block)
    }
}
