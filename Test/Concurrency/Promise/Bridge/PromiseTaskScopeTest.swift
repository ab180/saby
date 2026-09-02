//
//  PromiseTaskScopeTest.swift
//  SabyConcurrencyTest
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseTaskScopeTest {
    enum SampleError: Error {
        case one
    }

    @Test
    func test__promise_resolves_async_value() async {
        let scope = PromiseTaskScope()
        let promise = scope.promise {
            () async throws(SampleError) -> Int in
            10
        }

        await PromiseTest.expect(
            promise: promise,
            state: .resolved(10),
            timeout: .seconds(1)
        )
        await assertIsEmpty(scope)
    }

    @Test
    func test__promise_rejects_async_error() async {
        let scope = PromiseTaskScope()
        let promise = scope.promise {
            () async throws(SampleError) -> Int in
            throw SampleError.one
        }

        await PromiseTest.expect(
            promise: promise,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        )
        await assertIsEmpty(scope)
    }

    @Test
    func test__promise_cancel_cancels_task() async {
        let scope = PromiseTaskScope()
        let promise: Promise<Int, Error> = scope.promise {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return 10
        }

        promise.cancel()

        await PromiseTest.expect(
            promise: promise,
            state: .canceled,
            timeout: .seconds(1)
        )
        await assertIsEmpty(scope)
    }

    @Test
    func test__deinit_scope_cancels_task() async {
        var scope: PromiseTaskScope? = PromiseTaskScope(cancelWhen: .deinit)
        let promise: Promise<Int, Error> = scope!.promise {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return 10
        }

        scope = nil

        await PromiseTest.expect(
            promise: promise,
            state: .canceled,
            timeout: .seconds(1)
        )
    }

    @Test
    func test__none_scope_allows_task_to_complete() async {
        var scope: PromiseTaskScope? = PromiseTaskScope(cancelWhen: .none)
        let promise: Promise<Int, Error> = scope!.promise {
            try await Task.sleep(nanoseconds: 1_000_000)
            return 10
        }

        scope = nil

        await PromiseTest.expect(
            promise: promise,
            state: .resolved(10),
            timeout: .seconds(1)
        )
    }
}

private extension PromiseTaskScopeTest {
    func assertIsEmpty(
        _ scope: PromiseTaskScope,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<100 {
            if await scope.isEmpty {
                return
            }
            try? await Task.sleep(nanoseconds: 1_000_000)
        }

        Issue.record("PromiseTaskScope did not release its task")
    }
}
