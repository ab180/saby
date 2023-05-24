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
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error in
            XCTAssertEqual(error as? PromiseTest.SampleError, PromiseTest.SampleError.one)
            end.signal()
            return 20
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__recover_from_resolve() {
        let promise =
        Promise.async {
            Promise<Int, Error>.resolved(10)
        }.recover { error in
            20
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__recover_throw_error_return_value() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error -> Int in
            throw PromiseTest.SampleError.two
        }

        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.two), timeout: .seconds(1))
    }
    
    func test__recover_throw_error_return_promise() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error -> Promise<Int, Error> in
            throw PromiseTest.SampleError.two
        }

        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.two), timeout: .seconds(1))
    }
    
    func test__recover_throw_error_return_never_promise() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error -> Promise<Int, Never> in
            throw PromiseTest.SampleError.two
        }

        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.two), timeout: .seconds(1))
    }
    
    func test__recover_return_resolved_promise() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error in
            return Promise<Int, Error>.resolved(10)
        }

        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__recover_return_rejected_promise() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error in
            return Promise.rejected(PromiseTest.SampleError.two)
        }

        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.two), timeout: .seconds(1))
    }
    
    func test__recover_return_canceled_promise() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error in
            return Promise<Int, Error>.canceled()
        }

        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__recover_return_resolved_never_promise() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error in
            return Promise<Int, Never>.resolved(10)
        }

        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__recover_return_canceled_never_promise() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error in
            return Promise<Int, Error>.canceled()
        }

        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__recover_from_reject_return_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        var promiseCancel: (() -> Void)?
        let recoverPromise = Promise<Void, Error>.pending().promise
        
        let promise = Promise<Void, Error> { resolve, reject, cancel, _ in
            promiseCancel = cancel
            throw PromiseTest.SampleError.one
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
