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
    func wait() throws -> Value {
        try waitPromise(self)
    }
}

extension Contract {
    func wait(_ block: () -> Void) throws -> Value {
        try waitContract(self, block)
    }
}
