//
//  ContractThenTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import XCTest
@testable import SabyConcurrency

final class ContractThenTest: XCTestCase {
    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__then_return_async_value() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value async throws -> Int in
            value + 1
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__then_throw_error_return_async_value() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { _ async throws -> Int in
            throw ContractTest.SampleError.one
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__then_throw_cancellation_error_return_async_value() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { _ async throws -> Int in
            throw CancellationError()
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(CancellationError()),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__then_cancel_async_task() {
        let taskStarted = DispatchSemaphore(value: 0)
        let taskCanceled = DispatchSemaphore(value: 0)
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { _ async throws -> Int in
            taskStarted.signal()
            do {
                while !Task.isCancelled {
                    try await Task.sleep(nanoseconds: 1_000_000)
                }
            }
            catch is CancellationError {
            }

            taskCanceled.signal()
            try Task.checkCancellation()

            return 20
        }

        contract0.resolve(10)
        PromiseTest.expect(semaphore: taskStarted, timeout: .seconds(1))
        contract.cancel()

        PromiseTest.expect(semaphore: taskCanceled, timeout: .seconds(1))
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {}
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__then_cancel_async_task_before_upstream_resolved() {
        let blockCalled = DispatchSemaphore(value: 0)
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { _ async throws -> Int in
            blockCalled.signal()
            return 20
        }

        contract.cancel()
        contract0.resolve(10)

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {}
        XCTAssertEqual(blockCalled.wait(timeout: .now() + .milliseconds(100)), .timedOut)
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__then_cancel_async_tasks_from_multiple_emissions() {
        let taskStarted = DispatchSemaphore(value: 0)
        let taskCanceled = DispatchSemaphore(value: 0)
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value async throws -> Int in
            taskStarted.signal()
            do {
                while !Task.isCancelled {
                    try await Task.sleep(nanoseconds: 1_000_000)
                }
            }
            catch is CancellationError {
            }

            taskCanceled.signal()
            try Task.checkCancellation()

            return value
        }

        contract0.resolve(10)
        contract0.resolve(20)

        PromiseTest.expect(semaphore: taskStarted, count: 2, timeout: .seconds(1))
        contract.cancel()
        PromiseTest.expect(semaphore: taskCanceled, count: 2, timeout: .seconds(1))
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {}
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__never_then_return_async_value() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value async -> Int in
            value + 1
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }

    @available(macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func test__then_return_async_value_schedule_sync() {
        let end = DispatchSemaphore(value: 0)
        let running = Atomic(false)
        let overlapped = Atomic(false)
        let values = Atomic([Int]())
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then(schedule: .sync) { value async -> Int in
            running.mutate { isRunning in
                if isRunning {
                    overlapped.mutate { _ in true }
                }

                return true
            }

            try? await Task.sleep(nanoseconds: 10_000_000)

            running.mutate { _ in false }
            return value
        }

        contract.subscribe(
            onResolved: { value in
                values.mutate { $0 + [value] }
                end.signal()
            },
            onRejected: { _ in },
            onCanceled: { XCTFail() }
        )

        contract0.resolve(10)
        contract0.resolve(20)

        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))

        XCTAssertFalse(overlapped.capture { $0 })
        XCTAssertEqual(values.capture { $0 }, [10, 20])
    }

    func test__then_return_value() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value in
            value + 1
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_throw_error_return_value() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value -> Int in
            throw ContractTest.SampleError.one
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_throw_error_return_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value -> Promise<Int, Error> in
            throw ContractTest.SampleError.one
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_throw_error_return_never_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value -> Promise<Int, Never> in
            throw ContractTest.SampleError.one
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_return_resolved_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value in
            Promise<Int, Error>.resolved(value + 1)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_return_rejected_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value in
            Promise<Int, Error>.rejected(ContractTest.SampleError.one)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_return_canceled_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value in
            Promise<Int, Error>.canceled()
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_return_resolved_never_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value in
            Promise<Int, Never>.resolved(value + 1)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_return_canceled_never_promise() {
        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { value in
            Promise<Int, Never>.canceled()
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_return_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let thenPromise = Promise<Int, Error>.pending().promise

        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { _ in
            contract0.cancel()
            end.signal()
            return thenPromise
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: thenPromise, state: .pending, timeout: .seconds(1))
    }

    func test__never_then_return_value() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value in
            value + 1
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_throw_error_return_value() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value -> Int in
            throw ContractTest.SampleError.one
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_throw_error_return_promise() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value -> Promise<Int, Error> in
            throw ContractTest.SampleError.one
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_throw_error_return_never_promise() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value -> Promise<Int, Never> in
            throw ContractTest.SampleError.one
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_return_resolved_promise() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value in
            Promise<Int, Error>.resolved(value + 1)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_return_rejected_promise() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value in
            Promise<Int, Error>.rejected(ContractTest.SampleError.one)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_return_canceled_promise() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value in
            Promise<Int, Error>.canceled()
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_return_resolved_never_promise() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value in
            Promise<Int, Never>.resolved(value + 1)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__never_then_return_canceled_never_promise() {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value in
            Promise<Int, Never>.canceled()
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    func test__then_schedule_sync() throws {
        let expect = (0...10000).map { $0 }

        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()

        var actual = [Int]()
        let contract = contract0
            .then(schedule: .sync) { value in
                promise0.then { _ in value }
            }
            .then {
                actual.append($0)
                return $0
            }

        try contract.wait(until: { $0 == 10000 }) {
            (0...10000).forEach {
                contract0.resolve($0)
            }
            promise0.resolve(())
        }

        XCTAssertEqual(actual, expect)
    }

    func test__then_schedule_sync_throw() throws {
        let expect = (0...10000).compactMap { $0 % 2 == 0 ? $0 : nil }

        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()

        var actual = [Int]()
        let contract = contract0
            .then(schedule: .sync) { value in
                promise0.then { _ in
                    if value % 2 == 0 {
                        return value
                    }
                    else {
                        throw ContractTest.SampleError.one
                    }
                }
            }
            .then {
                actual.append($0)
                return $0
            }
            .recover { _ in 0 }

        try contract.wait(until: { $0 == 10000 }) {
            (0...10000).forEach {
                contract0.resolve($0)
            }
            promise0.resolve(())
        }

        XCTAssertEqual(actual, expect)
    }
}
