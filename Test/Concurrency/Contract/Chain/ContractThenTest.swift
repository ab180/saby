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
        let contract0 = Contract<Int>()
        
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
    
    func test__then_return_promise() {
        let contract0 = Contract<Int>()
        
        let contract = contract0.then { value in
            Promise.resolved(value + 1)
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
    
    func test__then_return_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let trigger = Promise<Void>.pending()
        let thenPromise = Promise<Int>.pending().promise

        let contract0 = Contract<Int>()

        let contract = contract0.cancel(when: trigger.promise).then { _ in
            trigger.resolve(())
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
}
