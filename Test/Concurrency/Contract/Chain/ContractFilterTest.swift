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
        let contract0 = Contract<Int, Error>()

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
        let contract0 = Contract<String, Error>()

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
        let contract0 = Contract<String, Error>()

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
        let filterPromise = Promise<Int, Never>.pending().promise
        
        let contract0 = Contract<String, Error>()

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
    
    func test__never_filter_bool() {
        let contract0 = Contract<Int, Never>()

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
    
    func test__never_filter_non_null() {
        let contract0 = Contract<String, Never>()

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
    
    func test__never_filter_promise() {
        let contract0 = Contract<String, Never>()

        let contract = contract0.filter { Promise<URL?, Never>.resolved(URL(string: $0)) }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        ) {
            contract0.resolve("%")
            contract0.resolve("https://a.example")
        }
    }
    
    func test__never_filter_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let filterPromise = Promise<Int, Never>.pending().promise
        
        let contract0 = Contract<String, Never>()

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
    
    func test__filter_schedule_sync() throws {
        let expect = (0...10000)
            .compactMap { $0 % 2 == 0 ? $0 : nil }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        var actual = [Int]()
        let contract = contract0
            .filter(schedule: .sync) { value in
                promise0.then { _ in
                    if value % 2 == 0 {
                        return value
                    }
                    else {
                        return nil
                    }
                }
            }
            .then {
                actual.append($0)
                return $0
            }
        
        try contract.wait(until: { $0 == 10000 }) {
            (0...10000).forEach {
                contract0.resolve($0)
            }
            promise0.resolve(())
        }
        
        XCTAssertEqual(actual, expect)
    }
}
