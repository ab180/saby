//
//  ContractTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/06.
//

import XCTest
@testable import SabyConcurrency

final class ContractTest: XCTestCase {
    func test__init() {
        let contract = Contract<Void>()
        
        if contract.subscribers.count != 0 {
            XCTFail("Initialized Contract's subscribers' count is not 0")
        }
        
        if contract.queue != Contract.Setting.defaultQueue {
            XCTFail("Initialized Contract's queue is not default queue")
        }
    }
    
    func test__resolve() {
        let contract = Contract<Int>()
        
        ContractTest.expect(contract: contract,
                            state: .resolved(10),
                            timeout: .seconds(1))
        {
            contract.resolve(10)
        }
    }
    
    func test__reject() {
        let contract = Contract<Int>()
        
        ContractTest.expect(contract: contract,
                            state: .rejected(SampleError.one),
                            timeout: .seconds(1))
        {
            contract.reject(SampleError.one)
        }
    }
    
    func test__create() {
        let (contract, _, reject) = Contract<Int>.create()
        
        ContractTest.expect(contract: contract,
                            state: .rejected(SampleError.one),
                            timeout: .seconds(1))
        {
            reject(SampleError.one)
        }
    }
}
