//
//  ContractFilterTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/24.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct ContractFilterTest {
    @Test
    func test__filter_bool() async {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.filter { $0 % 2 == 0 }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(2),
            timeout: .seconds(1)
        ) {
            contract0.resolve(1)
            contract0.resolve(2)
        }
    }
    
    @Test
    func test__filter_non_null() async {
        let contract0 = Contract<String, Error>()

        let contract = contract0.filter { URL(string: $0) }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        ) {
            contract0.resolve("")
            contract0.resolve("https://a.example")
        }
    }
    
    @Test
    func test__filter_promise() async {
        let contract0 = Contract<String, Error>()

        let contract = contract0.filter { Promise.resolved(URL(string: $0)) }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        ) {
            contract0.resolve("")
            contract0.resolve("https://a.example")
        }
    }
    
    @Test
    func test__filter_promise_cancel() async {
        let end = AsyncLatch()
        let filterPromise = Promise<Int, Never>.pending().promise
        
        let contract0 = Contract<String, Error>()

        let contract = contract0.filter { _ in
            contract0.cancel()
            end.signal()
            return filterPromise
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve("10")
        }
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: filterPromise, state: .pending, timeout: .seconds(1))
    }
    
    @Test
    func test__never_filter_bool() async {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.filter { $0 % 2 == 0 }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(2),
            timeout: .seconds(1)
        ) {
            contract0.resolve(1)
            contract0.resolve(2)
        }
    }
    
    @Test
    func test__never_filter_non_null() async {
        let contract0 = Contract<String, Never>()

        let contract = contract0.filter { URL(string: $0) }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        ) {
            contract0.resolve("")
            contract0.resolve("https://a.example")
        }
    }
    
    @Test
    func test__never_filter_promise() async {
        let contract0 = Contract<String, Never>()

        let contract = contract0.filter { Promise<URL?, Never>.resolved(URL(string: $0)) }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        ) {
            contract0.resolve("")
            contract0.resolve("https://a.example")
        }
    }
    
    @Test
    func test__never_filter_promise_cancel() async {
        let end = AsyncLatch()
        let filterPromise = Promise<Int, Never>.pending().promise
        
        let contract0 = Contract<String, Never>()

        let contract = contract0.filter { _ in
            contract0.cancel()
            end.signal()
            return filterPromise
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve("10")
        }
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: filterPromise, state: .pending, timeout: .seconds(1))
    }
    
    @Test
    func test__filter_schedule_sync() async throws {
        let expect = (0...10000)
            .compactMap { $0 % 2 == 0 ? $0 : nil }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        let actual = LockedBox<[Int]>([])
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
            .then { value in
                actual.withValue { $0.append(value) }
                return value
            }
        
        try await contract.testValue(until: { $0 == 10000 }) {
            (0...10000).forEach {
                contract0.resolve($0)
            }
            promise0.resolve(())
        }
        
        #expect(actual.value == expect)
    }
}
