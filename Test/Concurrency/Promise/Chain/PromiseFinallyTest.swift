//
//  FinallyTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import XCTest
@testable import SabyConcurrency

final class PromiseFinallyTest: XCTestCase {
    func test__finally() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise {
            10
        }.finally {
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__finally_from_reject() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        Promise<Int> { () -> Int in
            throw PromiseTest.Error.one
        }.finally {
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
    
    func test__finally_cancel() {
        let end = DispatchSemaphore(value: 0)
        
        let trigger = Promise<Void>.pending()
        
        let promise = Promise.cancel(when: trigger.promise) {
            Promise<Int> { () -> Int in
                throw PromiseTest.Error.one
            }
        }
        .finally {
            trigger.resolve(())
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
