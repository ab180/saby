//
//  ContractRecoverTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/12/20.
//

import XCTest
@testable import SabyConcurrency

final class ContractRecoverTest: XCTestCase {
    func test__recover_return_value() {
        let contract0 = Contract<Int>()

        let contract = contract0.recover { error in
            10
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }
    }
}
