//
//  ContractCatchTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct ContractCatchTest {
    @Test
    func test__catch_return_value() async {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.catch { error in }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }
    }
}
