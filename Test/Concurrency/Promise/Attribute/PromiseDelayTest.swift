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
        let delayed = Promise.delay(.milliseconds(10)).then { 10 }
        let later = Promise<Int, Never> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                resolve(20)
            }
        }
        
        expectResolutionOrder(delayed, later, equals: [10, 20])
    }
    
    func test__delay_create_long() {
        let delayed = Promise.delay(.milliseconds(100)).then { 10 }
        let earlier = Promise<Int, Never> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
                resolve(20)
            }
        }
        
        expectResolutionOrder(delayed, earlier, equals: [20, 10])
    }
    
    func test__delay_short() {
        let delayed = Promise.delay(.milliseconds(100)).then { 10 }
        let earlier = PromiseTest.make { 20 }.delay(.milliseconds(10))
        
        expectResolutionOrder(delayed, earlier, equals: [20, 10])
    }

    func test__delay_long() {
        let delayed = Promise.delay(.milliseconds(10)).then { 10 }
        let later = PromiseTest.make { 20 }.delay(.milliseconds(100))
        
        expectResolutionOrder(delayed, later, equals: [10, 20])
    }
    
    func test__delay_cancel() {
        let end = DispatchSemaphore(value: 0)
        let pending = Promise<Int, Error>.pending()

        let promise0 = pending.promise
        let promise1 = promise0.delay(.milliseconds(100))
        let promise2 = promise1.then { _ in
            pending.cancel()
            end.signal()
        }

        pending.resolve(20)
        
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: promise2, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    func test__never_delay_create() {
        let promise = Promise.delay(.milliseconds(0))
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    func test__safe_delay() {
        let promise = PromiseTest.make {
            10
        }
        .delay(.milliseconds(0))
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    private func expectResolutionOrder<FirstFailure, SecondFailure>(
        _ first: Promise<Int, FirstFailure>,
        _ second: Promise<Int, SecondFailure>,
        equals expected: [Int]
    ) where
        FirstFailure: Error & Sendable,
        SecondFailure: Error & Sendable
    {
        let lock = NSLock()
        nonisolated(unsafe) var values: [Int] = []
        let end = DispatchSemaphore(value: 0)

        first.subscribe(
            onResolved: { value in
                lock.withLock { values.append(value) }
                end.signal()
            },
            onRejected: { _ in
                XCTFail("Expected resolution")
                end.signal()
            },
            onCanceled: {
                XCTFail("Expected resolution")
                end.signal()
            }
        )
        second.subscribe(
            onResolved: { value in
                lock.withLock { values.append(value) }
                end.signal()
            },
            onRejected: { _ in
                XCTFail("Expected resolution")
                end.signal()
            },
            onCanceled: {
                XCTFail("Expected resolution")
                end.signal()
            }
        )

        PromiseTest.expect(semaphore: end, count: 2, timeout: .seconds(1))
        XCTAssertEqual(lock.withLock { values }, expected)
    }
}
