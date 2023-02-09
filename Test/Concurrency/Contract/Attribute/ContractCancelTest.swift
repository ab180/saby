//
//  ContractCancelTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2023/02/06.
//

import XCTest
@testable import SabyConcurrency

final class ContractCancelTest: XCTestCase {
    func test__cancel() {
        let contract = Contract<Int>.canceled()
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract.resolve(0)
        }
    }
}
