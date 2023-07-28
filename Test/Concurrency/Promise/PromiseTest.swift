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
        
        guard case .pending = promise.state.capture({ $0 }) else {
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
        let promise = Promise.async {
            10
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_return_value_throw_error() {
        let promise = Promise.async { () -> Int in
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_resolve() {
        let promise = Promise.async {
            Promise.async {
                10
            }
        }
        
       PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_reject() {
        let promise = Promise.async {
            Promise.async { () -> Int in
                throw PromiseTest.SampleError.one
            }
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_throw_error() {
        let promise = Promise.async { () -> Promise<Int, Error> in
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
    
    func test__cancel_deinit() throws {
        weak var promise0: Promise<Void, Never>?
        weak var promise1: Promise<Void, Never>?
        let result = Atomic(false)
        
        try Promise<Void, Never> { resolve, reject in
            defer { resolve(()) }
            
            let promise00 = Promise<Void, Never>.resolved(())
            let promise11 = promise00.delay(.milliseconds(10)).then {
                result.mutate { _ in true }
                return ()
            }
            
            promise0 = promise00
            promise1 = promise11
        }.wait()
    
        XCTAssertNil(promise0)
        XCTAssertNotNil(promise1)
        
        try promise1!.wait()
        XCTAssertEqual(result.capture { $0 }, true)
    }
}
