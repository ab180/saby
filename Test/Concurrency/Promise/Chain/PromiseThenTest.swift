//
//  ThenTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/02.
//

import XCTest
@testable import SabyConcurrency

final class PromiseThenTest: XCTestCase {
    func test__then_return_void() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async {
            10
        }.then { value in
            XCTAssertEqual(value, 10)
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    func test__then_return_void_throw_error() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async {
            10
        }.then { value in
            XCTAssertEqual(value, 10)
            end.signal()
            
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__then_return_void_from_reject() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.then { value in
            XCTFail()
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__then_return_value() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async {
            10
        }.then { value -> Int in
            XCTAssertEqual(value, 10)
            end.signal()
            
            return 20
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__then_return_value_throw_error() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async {
            10
        }.then { value -> Int in
            XCTAssertEqual(value, 10)
            end.signal()
            
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__then_return_value_from_reject() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.then { value -> Int in
            XCTFail()
            
            return 20
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__then_return_promise() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async {
            10
        }.then { value -> Promise<Int, Error> in
            XCTAssertEqual(value, 10)
            end.signal()
            
            return Promise.async {
                20
            }
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__then_return_promise_throw_error() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async {
            10
        }.then { value -> Promise<Int, Error> in
            XCTAssertEqual(value, 10)
            end.signal()
            
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__then_return_rejected_promise() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise.async {
            10
        }.then { value -> Promise<Int, Error> in
            XCTAssertEqual(value, 10)
            end.signal()
            
            return Promise<Int, Error>.rejected(
                PromiseTest.SampleError.one
            )
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__then_return_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        var promiseCancel: (() -> Void)?
        let thenPromise = Promise<Void, Error>.pending().promise
        
        let promise0 = Promise<Int, Error> { resolve, reject, cancel, _ in
            promiseCancel = cancel
            resolve(10)
        }
        let promise1 = promise0.then { _ in
            promiseCancel?()
            end.signal()
            return thenPromise
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise1, state: .pending, timeout: .seconds(1))
        PromiseTest.expect(promise: thenPromise, state: .pending, timeout: .seconds(1))
    }
    
    func test__then_return_promise_from_reject() {
        let promise =
        Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }.then { value -> Promise<Int, Error> in
            XCTFail()
            
            return Promise.async {
                20
            }
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__never_then_return_value() {
        let promise =
        Promise.async {
            10
        }.then {
            $0 + 10
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__never_then_throw_error() {
        let promise =
        Promise.async {
            10
        }.then { value -> Promise<Int, Error> in
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__never_then_return_resolved_promise() {
        let promise =
        Promise.async {
            10
        }.then {
            Promise<Int, Error>.resolved($0 + 10)
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__never_then_return_rejected_promise() {
        let promise =
        Promise.async {
            10
        }.then { _ in
            Promise<Int, Error>.rejected(PromiseTest.SampleError.one)
        }
        
        XCTAssertTrue(promise is Promise)
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__never_then_return_canceled_promise() {
        let promise =
        Promise.async {
            10
        }.then { _ in
            Promise<Int, Never>.canceled()
        }
        
        XCTAssertTrue(promise is Promise)
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__never_then_return_resolved_never_promise() {
        let promise =
        Promise.async {
            10
        }.then {
            Promise<Int, Never>.resolved($0 + 10)
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__never_then_return_canceled_never_promise() {
        let promise =
        Promise.async {
            10
        }.then { _ in
            Promise<Int, Never>.canceled()
        }
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
