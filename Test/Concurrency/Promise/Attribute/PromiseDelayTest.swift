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
            Promise {
                20
            }.delay(.milliseconds(10))
        ])
        
        PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }

    func test__delay_long() {
        let promise = Promise.race([
            Promise.delay(.milliseconds(10)).then { 10 },
            Promise {
                20
            }.delay(.milliseconds(100))
        ])
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__delay_cancel() {
        let end = DispatchSemaphore(value: 0)
        
        let trigger = Promise<Void>.pending()
        
        let promise =
        Promise {
            20
        }
        .cancel(when: trigger.promise)
        .delay(.milliseconds(100))
        .then { _ in
            trigger.resolve(())
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
