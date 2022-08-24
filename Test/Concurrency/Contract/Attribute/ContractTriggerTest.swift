//
//  ContractTriggerTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import XCTest
@testable import SabyConcurrency

final class ContractTriggerTest: XCTestCase {
    func test__trigger_resolve() {
        let contract0 = Contract<Int>()
        let promise0 = Promise<Void>()
        
        let contract = contract0.trigger(when: promise0).then { value in
            value + 1
        }
        
        promise0.resolve(())
        
        ContractTest.expect(contract: contract,
                            state: .resolved(11),
                            timeout: .seconds(1))
        {
            contract0.resolve(10)
        }
    }
}
