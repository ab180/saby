//
//  ContractScheduleTest.swift
//  SabyConcurrencyTest
//

import XCTest
@testable import SabyConcurrency

final class ContractScheduleTest: XCTestCase {
    func test__sync_explicit_queue_accepts_cross_contract_work_in_resolve_order() {
        let queue = DispatchQueue(label: "co.ab180.saby.contract-schedule-test")
        let contractA = Contract<String, Never>.executing()
        let contractB = Contract<String, Never>.executing()
        let promiseA1 = Promise<Void, Never>.pending()
        let promiseA2 = Promise<Void, Never>.pending()
        let promiseB1 = Promise<Void, Never>.pending()
        let startedA1 = expectation(description: "A1 started")
        let startedA2 = expectation(description: "A2 started")
        let startedB1 = expectation(description: "B1 started")
        let initialQueueDrained = expectation(description: "initial queue drained")
        let started = Atomic<[String]>([])

        contractA.contract.then(on: queue, schedule: .sync) { value in
            started.mutate { $0 + [value] }
            switch value {
            case "A1":
                startedA1.fulfill()
                return promiseA1.promise
            case "A2":
                startedA2.fulfill()
                return promiseA2.promise
            default:
                XCTFail("Unexpected value: \(value)")
                return .resolved(())
            }
        }
        contractB.contract.then(on: queue, schedule: .sync) { value in
            started.mutate { $0 + [value] }
            startedB1.fulfill()
            return promiseB1.promise
        }

        contractA.resolve("A1")
        contractA.resolve("A2")
        contractB.resolve("B1")
        queue.async {
            initialQueueDrained.fulfill()
        }

        XCTAssertEqual(
            XCTWaiter().wait(for: [startedA1, initialQueueDrained], timeout: 1),
            .completed
        )
        XCTAssertEqual(started.capture { $0 }, ["A1"])

        promiseA1.resolve(())
        XCTAssertEqual(XCTWaiter().wait(for: [startedA2], timeout: 1), .completed)
        XCTAssertEqual(started.capture { $0 }, ["A1", "A2"])

        promiseA2.resolve(())
        XCTAssertEqual(XCTWaiter().wait(for: [startedB1], timeout: 1), .completed)
        XCTAssertEqual(started.capture { $0 }, ["A1", "A2", "B1"])
        promiseB1.resolve(())
    }

    func test__sync_different_explicit_queues_execute_independently() {
        let label = "co.ab180.saby.contract-schedule-test.independent"
        let queueA = DispatchQueue(label: label)
        let queueB = DispatchQueue(label: label)
        let contractA = Contract<Void, Never>.executing()
        let contractB = Contract<Void, Never>.executing()
        let promiseA = Promise<Void, Never>.pending()
        let startedA = expectation(description: "A started")
        let startedB = expectation(description: "B started")

        contractA.contract.then(on: queueA, schedule: .sync) {
            startedA.fulfill()
            return promiseA.promise
        }
        contractB.contract.then(on: queueB, schedule: .sync) {
            startedB.fulfill()
            return Promise<Void, Never>.resolved(())
        }

        contractA.resolve(())
        contractB.resolve(())

        XCTAssertEqual(
            XCTWaiter().wait(for: [startedA, startedB], timeout: 1),
            .completed
        )
        promiseA.resolve(())
    }

    func test__sync_omitted_queue_keeps_contracts_independent() {
        let sharedQueue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.omitted"
        )
        let contractA = Contract<Void, Never>.executing(on: sharedQueue)
        let contractB = Contract<Void, Never>.executing(on: sharedQueue)
        let promiseA = Promise<Void, Never>.pending()
        let startedA = expectation(description: "A started")
        let startedB = expectation(description: "B started")

        contractA.contract.then(schedule: .sync) {
            startedA.fulfill()
            return promiseA.promise
        }
        contractB.contract.then(schedule: .sync) {
            startedB.fulfill()
            return Promise<Void, Never>.resolved(())
        }

        contractA.resolve(())
        contractB.resolve(())

        XCTAssertEqual(
            XCTWaiter().wait(for: [startedA, startedB], timeout: 1),
            .completed
        )
        promiseA.resolve(())
    }

    func test__sync_omitted_queue_preserves_legacy_callback_queue() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.legacy-affinity"
        )
        let key = DispatchSpecificKey<String>()
        queue.setSpecific(key: key, value: "contract-queue")
        let contract = Contract<Void, Never>.executing(on: queue)
        let executed = expectation(description: "legacy callback executed")

        contract.contract.then(schedule: .sync) {
            XCTAssertNil(DispatchQueue.getSpecific(key: key))
            executed.fulfill()
            return Promise<Void, Never>.resolved(())
        }

        contract.resolve(())

        XCTAssertEqual(
            XCTWaiter().wait(for: [executed], timeout: 1),
            .completed
        )
    }

    func test__async_explicit_queue_does_not_wait_for_previous_promise() {
        let queue = DispatchQueue(label: "co.ab180.saby.contract-schedule-test.async")
        let contractA = Contract<Void, Never>.executing()
        let contractB = Contract<Void, Never>.executing()
        let promiseA = Promise<Void, Never>.pending()
        let startedA = expectation(description: "A started")
        let startedB = expectation(description: "B started")

        contractA.contract.then(on: queue, schedule: .async) {
            startedA.fulfill()
            return promiseA.promise
        }
        contractB.contract.then(on: queue, schedule: .async) {
            startedB.fulfill()
            return Promise<Void, Never>.resolved(())
        }

        contractA.resolve(())
        contractB.resolve(())

        XCTAssertEqual(
            XCTWaiter().wait(for: [startedA, startedB], timeout: 1),
            .completed
        )
        promiseA.resolve(())
    }

    func test__sync_explicit_queue_executes_block_on_requested_queue() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.affinity"
        )
        let key = DispatchSpecificKey<String>()
        let value = "requested-queue"
        queue.setSpecific(key: key, value: value)
        let contract = Contract<Void, Never>.executing()
        let executed = expectation(description: "executed on requested queue")

        contract.contract.then(on: queue, schedule: .sync) {
            XCTAssertEqual(DispatchQueue.getSpecific(key: key), value)
            executed.fulfill()
            return Promise<Void, Never>.resolved(())
        }

        contract.resolve(())

        XCTAssertEqual(
            XCTWaiter().wait(for: [executed], timeout: 1),
            .completed
        )
    }

    func test__sync_continues_after_all_terminal_paths() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.terminal"
        )
        let resolved = Contract<Void, Never>.executing()
        let recovered = Contract<Void, ScheduleTestError>.executing()
        let rejected = Contract<Void, Never>.executing()
        let canceled = Contract<Void, Never>.executing()
        let thrown = Contract<Void, Error>.executing()
        let filtered = Contract<Void, Never>.executing()
        let sentinel = Contract<Void, Never>.executing()
        let completed = expectation(description: "all terminal paths completed")
        let initialQueueDrained = expectation(description: "initial queue drained")
        let pending = Promise<Void, Never>.pending()
        var started = [String]()

        resolved.contract.then(on: queue, schedule: .sync) {
            started.append("resolved")
            return pending.promise
        }
        recovered.contract.recover(on: queue, schedule: .sync) { _ in
            started.append("recovered")
            return Promise<Void, Never>.resolved(())
        }
        rejected.contract.then(on: queue, schedule: .sync) {
            started.append("rejected")
            return Promise<Void, Error>.rejected(ScheduleTestError.failed)
        }
        canceled.contract.then(on: queue, schedule: .sync) {
            started.append("canceled")
            return Promise<Void, Never>.canceled()
        }
        thrown.contract.then(on: queue, schedule: .sync) { _ -> Promise<Void, Never> in
            started.append("thrown")
            throw ScheduleTestError.failed
        }
        _ = filtered.contract.filter(on: queue, schedule: .sync) {
            _ -> Promise<Void, Never>? in
            started.append("filtered")
            return nil
        }
        sentinel.contract.then(on: queue, schedule: .sync) {
            started.append("sentinel")
            completed.fulfill()
            return Promise<Void, Never>.resolved(())
        }

        resolved.resolve(())
        recovered.reject(.failed)
        rejected.resolve(())
        canceled.resolve(())
        thrown.resolve(())
        filtered.resolve(())
        sentinel.resolve(())
        queue.async {
            initialQueueDrained.fulfill()
        }

        XCTAssertEqual(
            XCTWaiter().wait(for: [initialQueueDrained], timeout: 1),
            .completed
        )
        XCTAssertEqual(started, ["resolved"])
        pending.resolve(())

        XCTAssertEqual(
            XCTWaiter().wait(for: [completed], timeout: 1),
            .completed
        )
        XCTAssertEqual(
            started,
            [
                "resolved",
                "recovered",
                "rejected",
                "canceled",
                "thrown",
                "filtered",
                "sentinel",
            ]
        )
    }

    func test__sync_allows_reentrant_resolve_on_same_queue() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.reentrant"
        )
        let contract = Contract<Int, Never>.executing()
        let completed = expectation(description: "reentrant values completed")
        var started = [Int]()

        contract.contract.then(on: queue, schedule: .sync) { value in
            started.append(value)
            if value < 100 {
                contract.resolve(value + 1)
            }
            else {
                completed.fulfill()
            }
            return Promise<Void, Never>.resolved(())
        }

        contract.resolve(0)

        XCTAssertEqual(
            XCTWaiter().wait(for: [completed], timeout: 2),
            .completed
        )
        XCTAssertEqual(started, Array(0...100))
    }

    func test__sync_multiple_subscribers_deliver_each_event_once_in_order() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.subscribers"
        )
        let contract = Contract<Int, Never>.executing()
        let completed = expectation(description: "all subscriber events completed")
        let eventCount = 500
        var actual = [String]()

        contract.contract.then(on: queue, schedule: .sync) { value in
            actual.append("A\(value)")
            return Promise<Void, Never>.resolved(())
        }
        contract.contract.then(on: queue, schedule: .sync) { value in
            actual.append("B\(value)")
            if actual.count == eventCount * 2 {
                completed.fulfill()
            }
            return Promise<Void, Never>.resolved(())
        }

        (0..<eventCount).forEach(contract.resolve)

        XCTAssertEqual(
            XCTWaiter().wait(for: [completed], timeout: 5),
            .completed
        )
        XCTAssertEqual(
            actual,
            (0..<eventCount).flatMap { ["A\($0)", "B\($0)"] }
        )
    }

    func test__sync_cross_contract_fifo_stress_exceeds_ten_thousand_events() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.stress"
        )
        let contractA = Contract<Int, Never>.executing()
        let contractB = Contract<Int, Never>.executing()
        let completed = expectation(description: "stress events completed")
        let eventCount = 10_001
        var actual = [Int]()

        let record: (Int) -> Promise<Void, Never> = { value in
            actual.append(value)
            if actual.count == eventCount {
                completed.fulfill()
            }
            return .resolved(())
        }
        contractA.contract.then(on: queue, schedule: .sync, record)
        contractB.contract.then(on: queue, schedule: .sync, record)

        for value in 0..<eventCount {
            if value.isMultiple(of: 2) {
                contractA.resolve(value)
            }
            else {
                contractB.resolve(value)
            }
        }

        XCTAssertEqual(
            XCTWaiter().wait(for: [completed], timeout: 30),
            .completed
        )
        XCTAssertEqual(actual, Array(0..<eventCount))
    }

    func test__sync_concurrent_producers_do_not_overlap_or_lose_events() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.concurrent"
        )
        let producerQueue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.producers",
            attributes: .concurrent
        )
        let contractA = Contract<Int, Never>.executing()
        let contractB = Contract<Int, Never>.executing()
        let completed = expectation(description: "concurrent events completed")
        let eventCount = 2_001
        let activeCount = Atomic(0)
        let overlapped = Atomic(false)
        let received = Atomic<Set<Int>>([])

        let record: (Int) -> Promise<Void, Never> = { value in
            if activeCount.mutate({ $0 + 1 }) != 1 {
                overlapped.mutate { _ in true }
            }
            let receivedCount = received.mutate { received in
                var received = received
                received.insert(value)
                return received
            }.count
            activeCount.mutate { $0 - 1 }
            if receivedCount == eventCount {
                completed.fulfill()
            }
            return .resolved(())
        }
        contractA.contract.then(on: queue, schedule: .sync, record)
        contractB.contract.then(on: queue, schedule: .sync, record)

        for value in 0..<eventCount {
            producerQueue.async {
                if value.isMultiple(of: 2) {
                    contractA.resolve(value)
                }
                else {
                    contractB.resolve(value)
                }
            }
        }

        XCTAssertEqual(
            XCTWaiter().wait(for: [completed], timeout: 10),
            .completed
        )
        XCTAssertFalse(overlapped.capture { $0 })
        XCTAssertEqual(received.capture { $0 }, Set(0..<eventCount))
    }

    func test__registry_keeps_coordinator_alive_while_work_is_pending() {
        let queue = DispatchQueue(
            label: "co.ab180.saby.contract-schedule-test.active-lifetime"
        )
        let registry = ContractScheduleCoordinatorRegistry.shared
        let pending = Promise<Void, Never>.pending()
        let firstStarted = expectation(description: "first work started")
        let initialQueueDrained = expectation(description: "initial queue drained")
        let secondStarted = expectation(description: "second work started")
        let secondQueueDrained = expectation(description: "second queue drained")
        let didStartSecond = Atomic(false)
        weak var weakCoordinator: ContractScheduleCoordinator?
        var first: ContractExecuting<Void, Never>? = Contract.executing()
        var firstOutput: Contract<Void, Never>? = first?.contract.then(
            on: queue,
            schedule: .sync
        ) {
            firstStarted.fulfill()
            return pending.promise
        }

        XCTAssertNotNil(firstOutput)
        weakCoordinator = registry.coordinator(for: queue)
        first?.resolve(())
        queue.async {
            initialQueueDrained.fulfill()
        }
        XCTAssertEqual(
            XCTWaiter().wait(
                for: [firstStarted, initialQueueDrained],
                timeout: 1
            ),
            .completed
        )

        first = nil
        XCTAssertNotNil(weakCoordinator)

        let second = Contract<Void, Never>.executing()
        second.contract.then(on: queue, schedule: .sync) {
            didStartSecond.mutate { _ in true }
            secondStarted.fulfill()
            return Promise<Void, Never>.resolved(())
        }
        second.resolve(())
        queue.async {
            secondQueueDrained.fulfill()
        }

        XCTAssertEqual(
            XCTWaiter().wait(for: [secondQueueDrained], timeout: 1),
            .completed
        )
        XCTAssertFalse(didStartSecond.capture { $0 })

        pending.resolve(())
        XCTAssertEqual(
            XCTWaiter().wait(for: [secondStarted], timeout: 1),
            .completed
        )
        firstOutput = nil
    }

    func test__registry_releases_queue_coordinator_and_contracts() {
        let registry = ContractScheduleCoordinatorRegistry.shared
        let initialCount = registry.activeCount
        weak var weakQueue: DispatchQueue?
        weak var weakCoordinator: ContractScheduleCoordinator?
        weak var weakInput: Contract<Void, Never>?
        weak var weakOutput: Contract<Void, Never>?

        autoreleasepool {
            var queue: DispatchQueue? = DispatchQueue(
                label: "co.ab180.saby.contract-schedule-test.release"
            )
            var input: ContractExecuting<Void, Never>? = Contract.executing()
            var output: Contract<Void, Never>? = input?.contract.then(
                on: queue!,
                schedule: .sync
            ) {
                Promise<Void, Never>.resolved(())
            }

            weakQueue = queue
            weakInput = input?.contract
            weakOutput = output
            weakCoordinator = registry.coordinator(for: queue!)

            let completed = expectation(description: "release work completed")
            output?.subscribe(
                onResolved: { _ in completed.fulfill() },
                onRejected: { _ in },
                onCanceled: {}
            )
            input?.resolve(())
            XCTAssertEqual(
                XCTWaiter().wait(for: [completed], timeout: 1),
                .completed
            )

            output = nil
            input = nil
            queue = nil
        }

        XCTAssertNil(weakOutput)
        XCTAssertNil(weakInput)
        XCTAssertNil(weakCoordinator)
        XCTAssertNil(weakQueue)
        XCTAssertEqual(registry.activeCount, initialCount)
    }
}

private enum ScheduleTestError: Error {
    case failed
}
