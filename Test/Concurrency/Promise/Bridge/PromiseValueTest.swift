//
//  PromiseValueTest.swift
//  SabyConcurrencyTest
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseValueTest {
    @Test
    func test__value_returns_resolved_value() async throws {
        let value = try await Promise<Int, Error>.resolved(10).value()

        #expect(value == 10)
    }

    @Test
    func test__value_throws_rejected_error() async {
        do {
            _ = try await Promise<Int, Error>.rejected(PromiseTest.SampleError.one).value()
            Issue.record("Expected rejection")
        } catch {
            #expect(
                error.localizedDescription ==
                PromiseTest.SampleError.one.localizedDescription
            )
        }
    }

    @Test
    func test__value_throws_cancellation_error() async {
        do {
            let promise: Promise<Int, Error> = PromiseTest.canceled()
            _ = try await promise.value()
            Issue.record("Expected cancellation")
        } catch {
            #expect(error is CancellationError)
        }
    }

    @Test
    func test__task_cancellation_preserves_promise_by_default() async {
        let pending = Promise<Int, Error>.pending()
        let task = Task { try await pending.promise.value() }

        task.cancel()

        do {
            _ = try await task.value
            Issue.record("Expected cancellation")
        } catch {
            #expect(error is CancellationError)
        }
        #expect(pending.promise.capture().isPending)
    }

    @Test
    func test__task_cancellation_can_cancel_promise() async {
        let pending = Promise<Int, Error>.pending()
        let task = Task {
            try await pending.promise.value(cancelOnTaskCancellation: true)
        }

        task.cancel()

        do {
            _ = try await task.value
            Issue.record("Expected cancellation")
        } catch {
            #expect(error is CancellationError)
        }
        #expect(pending.promise.capture().isCanceled)
    }
}
