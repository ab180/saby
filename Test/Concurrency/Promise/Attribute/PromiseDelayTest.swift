//
//  PromiseDelayTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/08/19.
//

import XCTest
@testable import SabyConcurrency

final class PromiseDelayTest: XCTestCase {
    func test__delay_create_short() {
        let promise = Promise.race([
            Promise.delay(.milliseconds(10)).then { 10 },
            Promise { resolve, reject in
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                    resolve(20)
                }
            }
        ])
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__delay_create_long() {
        let promise = Promise.race([
            Promise.delay(.milliseconds(100)).then { 10 },
            Promise { resolve, reject in
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
                    resolve(20)
                }
            }
        ])
        
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    func test__delay_short() {
        let promise = Promise.race([
            Promise.delay(.milliseconds(100)).then { 10 },
            Promise.async {
                20
            }.delay(.milliseconds(10))
        ])
        
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }

    func test__delay_long() {
        let promise = Promise.race([
            Promise.delay(.milliseconds(10)).then { 10 },
            Promise.async {
                20
            }.delay(.milliseconds(100))
        ])
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__delay_cancel() {
        let end = DispatchSemaphore(value: 0)
        var promiseCancel: (() -> Void)?
        
        let promise0 = Promise<Int, Error> { resolve, reject, cancel, _ in
            promiseCancel = cancel
            resolve(20)
        }
        let promise1 = promise0.delay(.milliseconds(100))
        let promise2 = promise1.then { _ in
            promiseCancel?()
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise2, state: .canceled, timeout: .seconds(1))
    }
    
    func test__never_delay_create() {
        let promise = Promise.delay(.milliseconds(0))
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    func test__safe_delay() {
        let promise = Promise.async {
            10
        }
        .delay(.milliseconds(0))
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
}
