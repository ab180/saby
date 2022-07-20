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
        Promise {
            10
        }.then { value in
            XCTAssertEqual(value, 10)
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(()), timeout: .seconds(1))
    }
    
    func test__then_return_void_throw_error() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise {
            10
        }.then { value in
            XCTAssertEqual(value, 10)
            end.signal()
            
            throw PromiseTest.Error.one
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__then_return_void_from_reject() {
        let promise =
        Promise<Int> { () -> Int in
            throw PromiseTest.Error.one
        }.then { value in
            XCTFail()
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__then_return_value() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise {
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
        Promise {
            10
        }.then { value -> Int in
            XCTAssertEqual(value, 10)
            end.signal()
            
            throw PromiseTest.Error.one
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__then_return_value_from_reject() {
        let promise =
        Promise<Int> { () -> Int in
            throw PromiseTest.Error.one
        }.then { value -> Int in
            XCTFail()
            
            return 20
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__then_return_promise() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise {
            10
        }.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            end.signal()
            
            return Promise {
                20
            }
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__then_return_promise_throw_error() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise {
            10
        }.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            end.signal()
            
            throw PromiseTest.Error.one
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__then_return_rejected_promise() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise {
            10
        }.then { value -> Promise<Int> in
            XCTAssertEqual(value, 10)
            end.signal()
            
            return Promise.rejected(
                PromiseTest.Error.one
            )
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__then_return_promise_from_reject() {
        let promise =
        Promise<Int> { () -> Int in
            throw PromiseTest.Error.one
        }.then { value -> Promise<Int> in
            XCTFail()
            
            return Promise {
                20
            }
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
}
