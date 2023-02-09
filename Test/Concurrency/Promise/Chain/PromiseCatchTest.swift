//
//  CatchTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import XCTest
@testable import SabyConcurrency

final class PromiseCatchTest: XCTestCase {
    func test__catch() {
        let promise =
        Promise {
            10
        }.catch { error in
            XCTFail()
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__catch_from_reject() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise<Int> { () -> Int in
            throw PromiseTest.Error.one
        }.catch { error in
            XCTAssertEqual(error as? PromiseTest.Error, PromiseTest.Error.one)
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__catch_cancel() {
        let end = DispatchSemaphore(value: 0)
        var promiseCancel: (() -> Void)?
        
        let promise = Promise<Int> { resolve, reject, cancel, _ in
            promiseCancel = cancel
            throw PromiseTest.Error.one
        }
        .catch { error in
            promiseCancel?()
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
