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
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(2),
            timeout: .seconds(1)
        ) {
            contract0.resolve(1)
            contract0.resolve(2)
        }
    }
    
    func test__filter_non_null() {
        let contract0 = Contract<String>()

        let contract = contract0.filter { URL(string: $0) }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        ) {
            contract0.resolve("%")
            contract0.resolve("https://a.example")
        }
    }
    
    func test__filter_promise() {
        let contract0 = Contract<String>()

        let contract = contract0.filter { Promise.resolved(URL(string: $0)) }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        ) {
            contract0.resolve("%")
            contract0.resolve("https://a.example")
        }
    }
    
    func test__filter_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let filterPromise = Promise<Int>.pending().promise
        
        let contract0 = Contract<String>()

        let contract = contract0.filter { _ in
            contract0.cancel()
            end.signal()
            return filterPromise
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve("10")
        }
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: filterPromise, state: .canceled, timeout: .seconds(1))
    }
}
