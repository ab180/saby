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
        let contract0 = Contract<Int>()

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
        let contract0 = Contract<Int>()

        let contract = contract0.recover { error in
            Promise.resolved(10)
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
        let trigger = Promise<Void>.pending()
        let recoverPromise = Promise<Int>.pending().promise
        
        let contract0 = Contract<Int>()

        let contract = Contract.cancel(when: trigger.promise) {
            contract0
        }.recover { _ in
            trigger.resolve(())
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
}
