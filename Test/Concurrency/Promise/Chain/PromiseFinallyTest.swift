//
//  PromiseFinallyTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseFinallyTest {
    @Test
    func test__finally() async {
        let end = AsyncLatch()

        let promise = PromiseTest.make { 10 }.finally {
            end.signal()
        }

        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    @Test
    func test__finally_from_reject() async {
        let end = AsyncLatch()

        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.finally {
            end.signal()
        }

        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }

    @Test
    func test__finally_cancel() async {
        let end = AsyncLatch()
        let pending = Promise<Int, Error>.pending()

        let promise1 = pending.promise.finally {
            pending.cancel()
            end.signal()
        }

        pending.reject(PromiseTest.SampleError.one)

        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise1, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
}
