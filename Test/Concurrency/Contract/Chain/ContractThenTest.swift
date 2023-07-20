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
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            value + 1
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_throw_error_return_value() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value -> Int in
            throw ContractTest.SampleError.one
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_throw_error_return_promise() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value -> Promise<Int, Error> in
            throw ContractTest.SampleError.one
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_throw_error_return_never_promise() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value -> Promise<Int, Never> in
            throw ContractTest.SampleError.one
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_return_resolved_promise() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.resolved(value + 1)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_return_rejected_promise() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.rejected(ContractTest.SampleError.one)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_return_canceled_promise() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.canceled()
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_return_resolved_never_promise() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Never>.resolved(value + 1)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_return_canceled_never_promise() {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Never>.canceled()
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_return_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let thenPromise = Promise<Int, Error>.pending().promise

        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { _ in
            contract0.cancel()
            end.signal()
            return thenPromise
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: thenPromise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__never_then_return_value() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            value + 1
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_throw_error_return_value() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value -> Int in
            throw ContractTest.SampleError.one
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_throw_error_return_promise() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value -> Promise<Int, Error> in
            throw ContractTest.SampleError.one
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_throw_error_return_never_promise() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value -> Promise<Int, Never> in
            throw ContractTest.SampleError.one
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_return_resolved_promise() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.resolved(value + 1)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_return_rejected_promise() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.rejected(ContractTest.SampleError.one)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_return_canceled_promise() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.canceled()
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_return_resolved_never_promise() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Never>.resolved(value + 1)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__never_then_return_canceled_never_promise() {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Never>.canceled()
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    func test__then_schedule_sync() throws {
        let expect = (0...10000).map { $0 }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        var actual = [Int]()
        let contract = contract0
            .then(schedule: .sync) { value in
                promise0.then { _ in value }
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
    
    func test__then_schedule_sync_throw() throws {
        let expect = (0...10000).compactMap { $0 % 2 == 0 ? $0 : nil }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        var actual = [Int]()
        let contract = contract0
            .then(schedule: .sync) { value in
                promise0.then { _ in
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
