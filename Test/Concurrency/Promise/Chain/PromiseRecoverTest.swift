//
//  PromiseRecoverTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/12/20.
//

import XCTest
@testable import SabyConcurrency

final class PromiseRecoverTest: XCTestCase {
    func test__recover() {
        let promise =
        Promise {
            10
        }.recover { error in
            20
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__recover_from_reject() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise<Int> { () -> Int in
            throw PromiseTest.Error.one
        }.recover { error in
            XCTAssertEqual(error as? PromiseTest.Error, PromiseTest.Error.one)
            end.signal()
            return 20
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__recover_from_reject_return_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        var promiseCancel: (() -> Void)?
        let recoverPromise = Promise<Void>.pending().promise
        
        let promise = Promise<Void> { resolve, reject, cancel, _ in
            promiseCancel = cancel
            throw PromiseTest.Error.one
        }
        .recover { error in
            promiseCancel?()
            end.signal()
            return recoverPromise
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
        PromiseTest.expect(promise: recoverPromise, state: .canceled, timeout: .seconds(1))
    }
}
