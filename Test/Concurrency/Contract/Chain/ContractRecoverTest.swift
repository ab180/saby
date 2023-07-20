//
//  ContractRecoverTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/12/20.
//

import XCTest
@testable import SabyConcurrency

final class ContractRecoverTest: XCTestCase {
    func test__recover_return_value() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.recover { error in
            10
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }
    }
    
    func test__recover_return_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.recover { error in
            Promise<Int, Error>.resolved(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }
    }
    
    func test__recover_return_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let recoverPromise = Promise<Int, Error>.pending().promise
        
        let contract0 = Contract<Int, Error>()

        let contract = contract0.recover { _ in
            contract0.cancel()
            end.signal()
            return recoverPromise
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: recoverPromise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__recover_schedule_sync() throws {
        struct IntError: Error {
            let value: Int
        }
        
        let expect = (0...10000).map { $0 }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        var actual = [Int]()
        let contract = contract0
            .then { value -> Int in
                throw IntError(value: value)
            }
            .recover(schedule: .sync) { error in
                let error = error as! IntError
                return promise0.then { _ in error.value }
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
    
    func test__recover_schedule_sync_throw() throws {
        struct IntError: Error {
            let value: Int
        }
        
        let expect = (0...10000).compactMap { $0 % 2 == 0 ? $0 : nil }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        var actual = [Int]()
        let contract = contract0
            .then { value -> Int in
                throw IntError(value: value)
            }
            .recover(schedule: .sync) { error in
                let value = (error as! IntError).value
                return promise0.then {
                    if value % 2 == 0 {
                        return value
                    }
                    else {
                        throw ContractTest.SampleError.one
                    }
                }
            }
            .then {
                actual.append($0)
                return $0
            }
            .recover { _ in 0 }
        
        try contract.wait(until: { $0 == 10000 }) {
            (0...10000).forEach {
                contract0.resolve($0)
            }
            promise0.resolve(())
        }
        
        XCTAssertEqual(actual, expect)
    }
}
