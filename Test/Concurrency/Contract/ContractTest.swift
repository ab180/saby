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
    }
    
    func test__resolve() {
        let contract = Contract<Int>()
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract.resolve(10)
        }
    }
    
    func test__reject() {
        let contract = Contract<Int>()
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        ) {
            contract.reject(SampleError.one)
        }
    }
    
    func test__executing_resolve() {
        let executing = Contract<Int>.executing()
        
        ContractTest.expect(
            contract: executing.contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            executing.resolve(10)
        }
    }
    
    func test__executing_reject() {
        let executing = Contract<Int>.executing()
        
        ContractTest.expect(
            contract: executing.contract,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        ) {
            executing.reject(SampleError.one)
        }
    }
    
    func test__executing_cancel() {
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        
        let executing = Contract<Int>.executing()

        ContractTest.expect(
            contract: executing.contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            executing.onCancel {
                expect.fulfill()
            }
            executing.contract.cancel()
        }

        XCTAssertEqual(XCTWaiter().wait(for: [expect], timeout: 1), .completed)
    }
}
