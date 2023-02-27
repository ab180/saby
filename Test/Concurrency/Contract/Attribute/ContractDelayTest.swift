//
//  ContractDelayTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import XCTest
@testable import SabyConcurrency

final class ContractDelayTest: XCTestCase {
    func test__delay_resolve() {
        let contract0 = Contract<Int, Error>()
        let promise0 = Promise<Void, Never>()
        
        let contract = contract0.delay(until: promise0).then { value in
            value + 1
        }
        
        promise0.resolve(())
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }
    
    func test__delay_cancel() {
        let contract0 = Contract<Int, Error>()
        let promise0 = Promise<Void, Never>()
        
        let contract = contract0.delay(until: promise0).then { value in
            value + 1
        }
        
        promise0.cancel()
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }
    
    func test__safe_delay_resolve() {
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        let contract = contract0.delay(until: promise0).then { value in
            value + 1
        }
        
        promise0.resolve(())
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }
    
    func test__safe_delay_cancel() {
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        let contract = contract0.delay(until: promise0).then { value in
            value + 1
        }
        
        promise0.cancel()
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }
}
