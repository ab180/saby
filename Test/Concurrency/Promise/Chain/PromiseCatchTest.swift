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
        Promise.async {
            10
        }
        
        promise.finally {
            XCTAssertTrue(promise.isResolved)
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__catch_from_reject() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }
        .catch { error in
            XCTAssertEqual(error as? PromiseTest.SampleError, PromiseTest.SampleError.one)
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__catch_cancel() {
        let end = DispatchSemaphore(value: 0)
        var promiseCancel: (() -> Void)?
        
        let promise = Promise<Int, Error> { resolve, reject, cancel, _ in
            promiseCancel = cancel
            throw PromiseTest.SampleError.one
        }
        .catch { error in
            promiseCancel?()
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
