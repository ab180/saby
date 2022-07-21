//
//  ContractFinallyTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import XCTest
@testable import SabyConcurrency

final class ContractFinallyTest: XCTestCase {
    func test__finally_return_value() {
        let contract0 = Contract<Int>()

        let contract = contract0.finally {}
        
        ContractTest.expect(contract: contract,
                            state: .resolved(10),
                            timeout: .seconds(1))
        {
            contract0.resolve(10)
        }
        
        ContractTest.expect(contract: contract,
                            state: .rejected(ContractTest.SampleError.one),
                            timeout: .seconds(1))
        {
            contract0.reject(ContractTest.SampleError.one)
        }
    }
}
