//
//  ConcurrencyBridgeTest.swift
//  SabyConcurrencyTest
//
//  Created by mjgu on 2026/09/14.
//

import XCTest
@testable import SabyConcurrency

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class ConcurrencyBridgeTest: XCTestCase {
    enum SampleError: Error { case one }

    func testValueResolutionAndRejection() async throws {
        let value = try await Promise<Int, Never>.resolved(10).value()
        XCTAssertEqual(value, 10)
        do {
            _ = try await Promise<Int, Error>.rejected(SampleError.one).value()
            XCTFail("Expected rejection")
        } catch {
            XCTAssertEqual(error as? SampleError, .one)
        }
    }

    func testValueFromCanceledPromise() async {
        do {
            _ = try await Promise<Int, Never>.canceled().value()
            XCTFail("Expected cancellation")
        } catch { XCTAssertTrue(error is CancellationError) }
    }

    func testCanceledWaiterPreservesSharedPromise() async throws {
        let pending = Promise<Int, Error>.pending()
        let canceled = Task { try await pending.promise.value() }
        let survivor = Task { try await pending.promise.value() }
        canceled.cancel()
        do {
            _ = try await canceled.value
            XCTFail("Expected cancellation")
        } catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertTrue(pending.promise.isPending)
        pending.resolve(42)
        let value = try await survivor.value
        XCTAssertEqual(value, 42)
    }

    func testCancellationCanCancelSourcePromise() async {
        let pending = Promise<Int, Error>.pending()
        let task = Task { try await pending.promise.value(cancelOnTaskCancellation: true) }
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertTrue(pending.promise.isCanceled)
    }

    func testAlreadyCanceledTaskDoesNotSuspend() async {
        let pending = Promise<Int, Error>.pending()
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await pending.promise.value()
        }
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch { XCTAssertTrue(error is CancellationError) }
        XCTAssertTrue(pending.promise.isPending)
        pending.cancel()
    }

    func testResolutionRacingCancellationResumesOnce() async {
        for _ in 0..<100 {
            let pending = Promise<Int, Error>.pending()
            let task = Task { try await pending.promise.value() }
            DispatchQueue.global().async { pending.resolve(7) }
            task.cancel()
            do {
                let value = try await task.value
                XCTAssertEqual(value, 7)
            } catch { XCTAssertTrue(error is CancellationError) }
        }
    }

    func testStreamKeepsRejectionNonterminalAndPreservesOrder() async {
        let source = Contract<Int, SampleError>.executing()
        let stream = source.contract.stream
        source.resolve(1)
        source.reject(.one)
        source.resolve(2)
        source.cancel()
        var events: [String] = []
        for await event in stream {
            switch event {
            case .success(let value): events.append("value:\(value)")
            case .failure: events.append("error")
            }
        }
        XCTAssertEqual(events, ["value:1", "error", "value:2"])
    }

    func testNeverStreamAndAlreadyCanceledStream() async {
        let source = Contract<Int, Never>.executing()
        let stream: AsyncStream<Int> = source.contract.stream
        source.resolve(1)
        source.resolve(2)
        source.cancel()
        var values: [Int] = []
        for await value in stream { values.append(value) }
        XCTAssertEqual(values, [1, 2])
        let canceled = Contract<Int, SampleError>.canceled()
        var iterator = canceled.stream.makeAsyncIterator()
        let event = await iterator.next()
        XCTAssertNil(event)
    }

    func testCancelingStreamConsumerPreservesSource() async {
        let source = Contract<Int, SampleError>.executing()
        let stream = source.contract.stream
        let task = Task { for await _ in stream {} }
        task.cancel()
        await task.value
        XCTAssertTrue(source.contract.isExecuting)
        source.cancel()
    }

    func testTaskScopeResolvesAndReleasesCompletedTasks() async throws {
        let scope = PromiseTaskScope()
        let promise: Promise<Int, Never> = scope.promise { 10 }
        let value = try await promise.value()
        XCTAssertEqual(value, 10)
        for _ in 0..<100 where !scope.isEmpty {
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        XCTAssertTrue(scope.isEmpty)
    }

    func testTaskScopeRejects() async {
        let scope = PromiseTaskScope()
        let promise: Promise<Int, Error> = scope.promise { throw SampleError.one }
        do {
            _ = try await promise.value()
            XCTFail("Expected rejection")
        } catch { XCTAssertEqual(error as? SampleError, .one) }
    }

    func testTaskScopeCancellationReachesRunningTask() async {
        let scope = PromiseTaskScope()
        let started = Promise<Void, Never>.pending()
        let stopped = Promise<Void, Never>.pending()
        let promise: Promise<Int, Error> = scope.promise {
            started.resolve(())
            defer { stopped.resolve(()) }
            try await Task.sleep(nanoseconds: 5_000_000_000)
            return 10
        }
        _ = try? await started.promise.value()
        promise.cancel()
        _ = try? await stopped.promise.value()
        XCTAssertTrue(promise.isCanceled)
    }

    func testScopeDeinitCancelsOutstandingTask() async {
        var scope: PromiseTaskScope? = PromiseTaskScope(cancelWhen: .deinit)
        let promise: Promise<Int, Error> = scope!.promise {
            try await Task.sleep(nanoseconds: 5_000_000_000)
            return 10
        }
        scope = nil
        do {
            _ = try await promise.value()
            XCTFail("Expected cancellation")
        } catch { XCTAssertTrue(error is CancellationError) }
    }

    func testDefaultScopeDeinitAllowsCompletion() async throws {
        var scope: PromiseTaskScope? = PromiseTaskScope()
        let promise: Promise<Int, Error> = scope!.promise {
            try await Task.sleep(nanoseconds: 1_000_000)
            return 10
        }
        scope = nil
        let value = try await promise.value()
        XCTAssertEqual(value, 10)
    }
}
