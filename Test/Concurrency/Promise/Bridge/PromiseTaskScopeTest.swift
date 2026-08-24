//
//  PromiseTaskScopeTest.swift
//  SabyConcurrencyTest
//

import XCTest
@testable import SabyConcurrency

final class PromiseTaskScopeTest: XCTestCase {
    enum SampleError: Error {
        case one
    }

    func test__promise_resolves_async_value() async {
        let scope = PromiseTaskScope()
        let promise = scope.promise {
            () async throws(SampleError) -> Int in
            10
        }

        PromiseTest.expect(
            promise: promise,
            state: .resolved(10),
            timeout: .seconds(1)
        )
        await assertIsEmpty(scope)
    }

    func test__promise_rejects_async_error() async {
        let scope = PromiseTaskScope()
        let promise = scope.promise {
            () async throws(SampleError) -> Int in
            throw SampleError.one
        }

        PromiseTest.expect(
            promise: promise,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        )
        await assertIsEmpty(scope)
    }

    func test__promise_cancel_cancels_task() async {
        let scope = PromiseTaskScope()
        let promise: Promise<Int, Error> = scope.promise {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return 10
        }

        promise.cancel()

        PromiseTest.expect(
            promise: promise,
            state: .canceled,
            timeout: .seconds(1)
        )
        await assertIsEmpty(scope)
    }

    func test__deinit_scope_cancels_task() {
        var scope: PromiseTaskScope? = PromiseTaskScope(cancelWhen: .deinit)
        let promise: Promise<Int, Error> = scope!.promise {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return 10
        }

        scope = nil

        PromiseTest.expect(
            promise: promise,
            state: .canceled,
            timeout: .seconds(1)
        )
    }

    func test__none_scope_allows_task_to_complete() {
        var scope: PromiseTaskScope? = PromiseTaskScope(cancelWhen: .none)
        let promise: Promise<Int, Error> = scope!.promise {
            try await Task.sleep(nanoseconds: 1_000_000)
            return 10
        }

        scope = nil

        PromiseTest.expect(
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

        XCTFail("PromiseTaskScope did not release its task", file: file, line: line)
    }
}
