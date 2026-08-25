//
//  PromiseDelayTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/08/19.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseDelayTest {
    @Test
    func test__delay_create_short() async {
        let delayed = Promise.delay(.milliseconds(10)).then { 10 }
        let later = Promise<Int, Never> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                resolve(20)
            }
        }
        
        await expectResolutionOrder(delayed, later, equals: [10, 20])
    }
    
    @Test
    func test__delay_create_long() async {
        let delayed = Promise.delay(.milliseconds(100)).then { 10 }
        let earlier = Promise<Int, Never> { resolve, _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
                resolve(20)
            }
        }
        
        await expectResolutionOrder(delayed, earlier, equals: [20, 10])
    }
    
    @Test
    func test__delay_short() async {
        let delayed = Promise.delay(.milliseconds(100)).then { 10 }
        let earlier = PromiseTest.make { 20 }.delay(.milliseconds(10))
        
        await expectResolutionOrder(delayed, earlier, equals: [20, 10])
    }

    @Test
    func test__delay_long() async {
        let delayed = Promise.delay(.milliseconds(10)).then { 10 }
        let later = PromiseTest.make { 20 }.delay(.milliseconds(100))
        
        await expectResolutionOrder(delayed, later, equals: [10, 20])
    }
    
    @Test
    func test__delay_cancel() async {
        let end = AsyncLatch()
        let pending = Promise<Int, Error>.pending()

        let promise0 = pending.promise
        let promise1 = promise0.delay(.milliseconds(100))
        let promise2 = promise1.then { _ in
            pending.cancel()
            end.signal()
        }

        pending.resolve(20)
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise2, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    @Test
    func test__never_delay_create() async {
        let promise = Promise.delay(.milliseconds(0))
        
        await PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    @Test
    func test__safe_delay() async {
        let promise = PromiseTest.make {
            10
        }
        .delay(.milliseconds(0))
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    private func expectResolutionOrder<FirstFailure, SecondFailure>(
        _ first: Promise<Int, FirstFailure>,
        _ second: Promise<Int, SecondFailure>,
        equals expected: [Int]
    ) async where
        FirstFailure: Error & Sendable,
        SecondFailure: Error & Sendable
    {
        let values = LockedBox<[Int]>([])
        let end = AsyncLatch()

        first.subscribe(
            onResolved: { value in
                values.withValue { $0.append(value) }
                end.signal()
            },
            onRejected: { _ in
                Issue.record("Expected resolution")
                end.signal()
            },
            onCanceled: {
                Issue.record("Expected resolution")
                end.signal()
            }
        )
        second.subscribe(
            onResolved: { value in
                values.withValue { $0.append(value) }
                end.signal()
            },
            onRejected: { _ in
                Issue.record("Expected resolution")
                end.signal()
            },
            onCanceled: {
                Issue.record("Expected resolution")
                end.signal()
            }
        )

        #expect(await end.wait(count: 2, timeout: .seconds(1)))
        #expect(values.value == expected)
    }
}
