//
//  ContractDelayTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2023/03/01.
//

import XCTest
@testable import SabyConcurrency

final class ContractNextTest: XCTestCase {
    func test__next() {
        let contract = Contract<Int, Error>()
        let promise = contract.next()
        
        contract.resolve(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
}
