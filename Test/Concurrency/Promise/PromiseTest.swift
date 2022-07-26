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
        let promise = Promise<Int>()
        
        guard case .pending = promise.state else {
            XCTFail("Promise is not pending")
            return
        }
    }
    
    func test__init_with_resolver_resolve() {
        let promise = Promise<Int> { resolve, reject in
            resolve(10)
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_reject() {
        let promise = Promise<Int> { resolve, reject in
            reject(PromiseTest.Error.one)
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_throw_error() {
        let promise = Promise<Int> { resolve, reject in
            throw PromiseTest.Error.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__init_with_return_value() {
        let promise = Promise<Int> {
            10
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_return_value_throw_error() {
        let promise = Promise<Int> { () -> Int in
            throw PromiseTest.Error.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_resolve() {
        let promise = Promise<Int> {
            Promise {
                10
            }
        }
        
       PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_reject() {
        let promise = Promise<Int> {
            Promise<Int> { () -> Int in
                throw PromiseTest.Error.one
            }
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__init_with_return_promise_throw_error() {
        let promise = Promise<Int> { () -> Promise<Int> in
            throw PromiseTest.Error.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__resolve() {
        let promise = Promise<Int>()
        promise.resolve(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__reject() {
        let promise = Promise<Int>()
        promise.reject(PromiseTest.Error.one)
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__pending() {
        let (promise, _, _) = Promise<Int>.pending()
        
        PromiseTest.expect(promise: promise, state: .pending, timeout: .seconds(1))
    }
    
    func test__pending_resolve() {
        let (promise, resolve, _) = Promise<Int>.pending()
        resolve(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__pending_reject() {
        let (promise, _, reject) = Promise<Int>.pending()
        reject(PromiseTest.Error.one)
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__resolved() {
        let promise = Promise.resolved(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__rejected() {
        let promise = Promise<Int>.rejected(PromiseTest.Error.one)
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
}
