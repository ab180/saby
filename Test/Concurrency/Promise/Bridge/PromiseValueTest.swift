//
//  PromiseValueTest.swift
//  SabyConcurrencyTest
//

import XCTest
@testable import SabyConcurrency

final class PromiseValueTest: XCTestCase {
    func test__value_returns_resolved_value() async throws {
        let value = try await Promise<Int, Error>.resolved(10).value()

        XCTAssertEqual(value, 10)
    }

    func test__value_throws_rejected_error() async {
        do {
            _ = try await Promise<Int, Error>.rejected(PromiseTest.SampleError.one).value()
            XCTFail("Expected rejection")
        } catch {
            XCTAssertEqual(
                error.localizedDescription,
                PromiseTest.SampleError.one.localizedDescription
            )
        }
    }

    func test__value_throws_cancellation_error() async {
        do {
            _ = try await Promise<Int, Error>.canceled().value()
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
    }

    func test__task_cancellation_cancels_promise() async {
        let pending = Promise<Int, Error>.pending()
        let task = Task { try await pending.promise.value() }

        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
        let isCanceled = await pending.promise.isCanceled
        XCTAssertTrue(isCanceled)
    }

    func test__task_cancellation_can_preserve_shared_promise() async {
        let pending = Promise<Int, Error>.pending()
        let task = Task {
            try await pending.promise.value(cancelOnTaskCancellation: false)
        }

        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
        let isPending = await pending.promise.isPending
        XCTAssertTrue(isPending)

        pending.resolve(10)

        let isResolved = await pending.promise.isResolved
        XCTAssertTrue(isResolved)
    }
}
