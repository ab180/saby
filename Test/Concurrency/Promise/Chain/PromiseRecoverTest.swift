//
//  PromiseRecoverTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/12/20.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseRecoverTest {
    private enum RecoverError: Error {
        case two
    }

    @Test
    func test__recover() async {
        let end = AsyncLatch()

        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { error in
            #expect(error as? PromiseTest.SampleError == PromiseTest.SampleError.one)
            end.signal()
            return 20
        }

        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }

    @Test
    func test__recover_from_resolve() async {
        let promise = Promise<Int, Error>.resolved(10).recover { _ in 20 }

        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    @Test
    func test__recover_throw_error_return_value() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ -> Int in
            throw RecoverError.two
        }

        await PromiseTest.expect(promise: promise, state: .rejected(RecoverError.two), timeout: .seconds(1))
    }

    @Test
    func test__recover_throw_error_return_promise() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ -> Promise<Int, Error> in
            throw RecoverError.two
        }

        await PromiseTest.expect(promise: promise, state: .rejected(RecoverError.two), timeout: .seconds(1))
    }

    @Test
    func test__recover_throw_error_return_never_promise() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ -> Promise<Int, Never> in
            throw RecoverError.two
        }

        await PromiseTest.expect(promise: promise, state: .rejected(RecoverError.two), timeout: .seconds(1))
    }

    @Test
    func test__recover_return_resolved_promise() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ in
            Promise<Int, Error>.resolved(10)
        }

        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    @Test
    func test__recover_return_rejected_promise() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ in
            Promise<Int, Error>.rejected(RecoverError.two)
        }

        await PromiseTest.expect(promise: promise, state: .rejected(RecoverError.two), timeout: .seconds(1))
    }

    @Test
    func test__recover_return_canceled_promise() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ in
            PromiseTest.canceled() as Promise<Int, Error>
        }

        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }

    @Test
    func test__recover_return_resolved_never_promise() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ in
            Promise<Int, Never>.resolved(10)
        }

        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    @Test
    func test__recover_return_canceled_never_promise() async {
        let promise = PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.recover { _ in
            PromiseTest.canceled() as Promise<Int, Error>
        }

        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }

    @Test
    func test__recover_from_reject_return_promise_cancel() async {
        let end = AsyncLatch()
        let pending = Promise<Void, Error>.pending()
        let recoverPromise = Promise<Void, Error>.pending().promise

        let promise1 = pending.promise.recover { _ in
            pending.cancel()
            end.signal()
            return recoverPromise
        }

        pending.reject(PromiseTest.SampleError.one)

        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise1, state: .pending, timeout: .seconds(1))
        await PromiseTest.expect(promise: recoverPromise, state: .pending, timeout: .seconds(1))
    }
}
