//
//  PromiseTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/02.
//

import XCTest
@testable import SabyConcurrency

final class PromiseTest: XCTestCase {
    func test__init() {
        let promise = Promise<Int, Error>()
        
        guard case .pending = promise.state else {
            XCTFail("Promise is not pending")
            return
        }
    }
    
    func test__init_with_resolver_resolve() {
        let promise = Promise<Int, Error> { resolve, reject in
            resolve(10)
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_reject() {
        let promise = Promise<Int, Error> { resolve, reject in
            reject(PromiseTest.SampleError.one)
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_throw_error() {
        let promise = Promise<Int, Error> { resolve, reject in
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_cancel() {
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        
        let promise = Promise<Int, Error> { resolve, reject, cancel, onCancel in
            onCancel {
                expect.fulfill()
            }
        }
        promise.cancel()
        
        XCTAssertEqual(XCTWaiter().wait(for: [expect], timeout: 1), .completed)
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__init_with_return_value() {
        let promise = Promise<Int, Error> {
            10
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_return_value_throw_error() {
        let promise = Promise<Int, Error> { () -> Int in
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_resolve() {
        let promise = Promise<Int, Error> {
            Promise {
                10
            }
        }
        
       PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_reject() {
        let promise = Promise<Int, Error> {
            Promise<Int, Error> { () -> Int in
                throw PromiseTest.SampleError.one
            }
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_throw_error() {
        let promise = Promise<Int, Error> { () -> Promise<Int, Error> in
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__resolve() {
        let promise = Promise<Int, Error>()
        promise.resolve(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__reject() {
        let promise = Promise<Int, Error>()
        promise.reject(PromiseTest.SampleError.one)
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__pending() {
        let pending = Promise<Int, Error>.pending()
        
        PromiseTest.expect(promise: pending.promise, state: .pending, timeout: .seconds(1))
    }
    
    func test__pending_resolve() {
        let pending = Promise<Int, Error>.pending()
        pending.resolve(10)
        
        PromiseTest.expect(promise: pending.promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__pending_reject() {
        let pending = Promise<Int, Error>.pending()
        pending.reject(PromiseTest.SampleError.one)
        
        PromiseTest.expect(promise: pending.promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__pending_cancel() {
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        
        let pending = Promise<Int, Error>.pending()
        pending.onCancel {
            expect.fulfill()
        }
        pending.promise.cancel()
        
        XCTAssertEqual(XCTWaiter().wait(for: [expect], timeout: 1), .completed)
        PromiseTest.expect(promise: pending.promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__resolved() {
        let promise = Promise<Int, Error>.resolved(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__rejected() {
        let promise = Promise<Int, Error>.rejected(PromiseTest.SampleError.one)
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__canceled() {
        let promise = Promise<Int, Error>.canceled()
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
