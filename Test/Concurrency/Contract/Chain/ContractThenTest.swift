//
//  ContractThenTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import XCTest
@testable import SabyConcurrency

final class ContractThenTest: XCTestCase {
    func test__then_return_value() {
        let contract0 = Contract<Int>()
        
        let contract = contract0.then { value in
            value + 1
        }
        
        ContractTest.expect(contract: contract,
                            state: .resolved(11),
                            timeout: .seconds(1))
        {
            contract0.resolve(10)
        }
        
        ContractTest.expect(contract: contract,
                            state: .resolved(21),
                            timeout: .seconds(1))
        {
            contract0.resolve(20)
        }
    }
    
    func test__then_return_promise_value() {
        let contract0 = Contract<Int>()
        
        let contract = contract0.then { value in
            Promise.resolved(value + 1)
        }
        
        ContractTest.expect(contract: contract,
                            state: .resolved(11),
                            timeout: .seconds(1))
        {
            contract0.resolve(10)
        }
        
        ContractTest.expect(contract: contract,
                            state: .resolved(21),
                            timeout: .seconds(1))
        {
            contract0.resolve(20)
        }
    }
}
