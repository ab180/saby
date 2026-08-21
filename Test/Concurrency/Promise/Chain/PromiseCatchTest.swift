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
        let end = DispatchSemaphore(value: 0)
        let promise =
        PromiseTest.make {
            10
        }
        
        promise.finally {
            end.signal()
        }

        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__catch_from_reject() {
        let end = DispatchSemaphore(value: 0)
        
        let promise =
        PromiseTest.make { () -> Int in
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
        let pending = Promise<Int, Error>.pending()

        let promise0 = pending.promise
        let promise1 = promise0.catch { error in
            pending.cancel()
            end.signal()
        }

        pending.reject(PromiseTest.SampleError.one)
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise1, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
}
