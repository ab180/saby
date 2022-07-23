//
//  ContractFilterTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/24.
//

import XCTest
@testable import SabyConcurrency

final class ContractFilterTest: XCTestCase {
    func test__filter_bool() {
        let contract0 = Contract<Int>()

        let contract = contract0.filter { $0 % 2 == 0 }
        
        ContractTest.expect(contract: contract,
                            state: .resolved(2),
                            timeout: .seconds(1))
        {
            contract0.resolve(1)
            contract0.resolve(2)
        }
    }
    
    func test__filter_non_null() {
        let contract0 = Contract<String>()

        let contract = contract0.filter { URL(string: $0) }
        
        ContractTest.expect(contract: contract,
                            state: .resolved(URL(string: "https://a.example")!),
                            timeout: .seconds(1))
        {
            contract0.resolve("%")
            contract0.resolve("https://a.example")
        }
    }
}
