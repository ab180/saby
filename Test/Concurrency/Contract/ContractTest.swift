//
//  ContractTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/06.
//

import XCTest
@testable import SabyConcurrency

final class ContractTest: XCTestCase {
    func test__repeated_resolve_and_reject_are_delivered_in_order() {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let lock = NSLock()
        nonisolated(unsafe) var values: [String] = []
        let callbacks = DispatchSemaphore(value: 0)

        contract.subscribe(
            on: queue,
            onResolved: { value in
                lock.withLock { values.append("resolve:\(value)") }
                callbacks.signal()
            },
            onRejected: { error in
                lock.withLock { values.append("reject:\(error)") }
                callbacks.signal()
            },
            onCanceled: {}
        )

        contract.resolve(1)
        contract.reject(.one)
        contract.resolve(2)
        contract.reject(.two)
        for _ in 0..<4 {
            XCTAssertEqual(callbacks.wait(timeout: .now() + 1), .success)
        }

        XCTAssertEqual(lock.withLock { values }, [
            "resolve:1",
            "reject:one",
            "resolve:2",
            "reject:two",
        ])
    }

    func test__cancel_waits_for_prior_events_and_suppresses_later_events() {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let lock = NSLock()
        nonisolated(unsafe) var values: [String] = []
        let canceled = DispatchSemaphore(value: 0)

        contract.subscribe(
            on: queue,
            onResolved: { value in lock.withLock { values.append("resolve:\(value)") } },
            onRejected: { error in lock.withLock { values.append("reject:\(error)") } },
            onCanceled: {
                lock.withLock { values.append("cancel") }
                canceled.signal()
            }
        )

        contract.resolve(1)
        contract.reject(.one)
        contract.cancel()
        contract.resolve(2)
        contract.reject(.two)
        XCTAssertEqual(canceled.wait(timeout: .now() + 1), .success)
        queue.sync {}

        XCTAssertEqual(lock.withLock { values }, ["resolve:1", "reject:one", "cancel"])
    }

    func test__concurrent_cancel_notifies_each_subscriber_once() {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let lock = NSLock()
        nonisolated(unsafe) var callbackCounts = Array(repeating: 0, count: 32)
        let callbacks = DispatchSemaphore(value: 0)

        for index in 0..<32 {
            contract.subscribe(on: queue) {
                lock.withLock { callbackCounts[index] += 1 }
                callbacks.signal()
            }
        }

        DispatchQueue.concurrentPerform(iterations: 1_000) { _ in
            contract.cancel()
        }
        for _ in 0..<32 {
            XCTAssertEqual(callbacks.wait(timeout: .now() + 1), .success)
        }

        XCTAssertEqual(lock.withLock { callbackCounts }, Array(repeating: 1, count: 32))
    }

    func test__concurrent_subscribe_emit_and_cancel_notifies_every_subscriber_once() {
        let iterationCount = 256
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function, attributes: .concurrent)
        let lock = NSLock()
        nonisolated(unsafe) var callbackCounts = Array(repeating: 0, count: iterationCount)
        let callbacks = DispatchGroup()

        DispatchQueue.concurrentPerform(iterations: iterationCount) { index in
            callbacks.enter()
            contract.subscribe(
                on: queue,
                onResolved: { _ in },
                onRejected: { _ in },
                onCanceled: {
                    lock.withLock { callbackCounts[index] += 1 }
                    callbacks.leave()
                }
            )

            switch index % 3 {
            case 0: contract.resolve(index)
            case 1: contract.reject(.one)
            default: contract.cancel()
            }
        }

        contract.cancel()
        XCTAssertEqual(callbacks.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(
            lock.withLock { callbackCounts },
            Array(repeating: 1, count: iterationCount)
        )
    }

    func test__late_subscriber_to_canceled_contract_is_notified_on_requested_queue() {
        let contract = Contract<Int, SampleError>.canceled()
        let queue = DispatchQueue(label: #function)
        let marker = QueueMarker()
        let lock = NSLock()
        nonisolated(unsafe) var callbackMarker: UInt8?
        let canceled = DispatchSemaphore(value: 0)
        queue.setSpecific(key: marker.key, value: 1)

        contract.subscribe(on: queue) {
            lock.withLock { callbackMarker = DispatchQueue.getSpecific(key: marker.key) }
            canceled.signal()
        }
        XCTAssertEqual(canceled.wait(timeout: .now() + 1), .success)

        XCTAssertEqual(lock.withLock { callbackMarker }, 1)
    }

    func test__active_cancel_uses_contract_queue() {
        let contractQueue = DispatchQueue(label: "\(#function).contract")
        let subscriberQueue = DispatchQueue(label: "\(#function).subscriber")
        let contract = Contract<Int, SampleError>.executing(on: contractQueue).contract
        let marker = QueueMarker()
        let lock = NSLock()
        nonisolated(unsafe) var callbackMarker: UInt8?
        let canceled = DispatchSemaphore(value: 0)
        contractQueue.setSpecific(key: marker.key, value: 1)
        subscriberQueue.setSpecific(key: marker.key, value: 2)

        contract.subscribe(on: subscriberQueue) {
            lock.withLock { callbackMarker = DispatchQueue.getSpecific(key: marker.key) }
            canceled.signal()
        }
        contract.cancel()
        XCTAssertEqual(canceled.wait(timeout: .now() + 1), .success)

        XCTAssertEqual(lock.withLock { callbackMarker }, 1)
    }

    func test__callback_can_resolve_reentrantly_without_deadlock() {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let lock = NSLock()
        nonisolated(unsafe) var values: [Int] = []
        let callbacks = DispatchSemaphore(value: 0)

        contract.subscribe(
            on: queue,
            onResolved: { value in
                lock.withLock { values.append(value) }
                if value == 1 {
                    contract.resolve(2)
                }
                callbacks.signal()
            },
            onRejected: { _ in },
            onCanceled: {}
        )

        contract.resolve(1)
        XCTAssertEqual(callbacks.wait(timeout: .now() + 1), .success)
        XCTAssertEqual(callbacks.wait(timeout: .now() + 1), .success)

        XCTAssertEqual(lock.withLock { values }, [1, 2])
    }

    func test__subscriber_deinit_can_reenter_contract_during_cancel() {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let tokenDeinitialized = DispatchSemaphore(value: 0)
        let cancelReturned = DispatchSemaphore(value: 0)

        do {
            let token = DeinitToken { [weak contract] in
                contract?.cancel()
                tokenDeinitialized.signal()
            }
            contract.subscribe(
                on: queue,
                onResolved: { _ in withExtendedLifetime(token) {} },
                onRejected: { _ in },
                onCanceled: {}
            )
        }

        DispatchQueue.global().async {
            contract.cancel()
            cancelReturned.signal()
        }

        XCTAssertEqual(tokenDeinitialized.wait(timeout: .now() + 1), .success)
        XCTAssertEqual(cancelReturned.wait(timeout: .now() + 1), .success)
    }

    func test__executing_deinit_cancels_contract() {
        let canceled = DispatchSemaphore(value: 0)
        weak var weakExecuting: ContractExecuting<Int, SampleError>?

        do {
            let executing = Contract<Int, SampleError>.executing(cancelWhen: .deinit)
            weakExecuting = executing
            executing.onCancel { canceled.signal() }
        }

        XCTAssertNil(weakExecuting)
        XCTAssertEqual(canceled.wait(timeout: .now() + 1), .success)
    }
    
    func test__resolve() {
        let contract = Contract<Int, Error>()
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract.resolve(10)
        }
    }
    
    func test__reject() {
        let contract = Contract<Int, Error>()
        
        ContractTest.expect(
            contract: contract,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        ) {
            contract.reject(SampleError.one)
        }
    }
    
    func test__cancel() {
        let contract = Contract<Int, Error>.canceled()
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract.resolve(0)
        }
    }
    
    func test__executing_resolve() {
        let executing = Contract<Int, Error>.executing()
        
        ContractTest.expect(
            contract: executing.contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            executing.resolve(10)
        }
    }
    
    func test__executing_reject() {
        let executing = Contract<Int, Error>.executing()
        
        ContractTest.expect(
            contract: executing.contract,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        ) {
            executing.reject(SampleError.one)
        }
    }
    
    func test__executing_cancel() {
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        
        let executing = Contract<Int, Error>.executing()

        ContractTest.expect(
            contract: executing.contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            executing.onCancel {
                expect.fulfill()
            }
            executing.contract.cancel()
        }

        XCTAssertEqual(XCTWaiter().wait(for: [expect], timeout: 1), .completed)
    }
    
    func test__executing_subscribe() {
        let executing = Contract<Int, Error>.executing()
        let contract0 = Contract<Int, Error>()
        let contract1 = Contract<Int, Error>()
        
        executing.subscribe([contract0, contract1])
        
        ContractTest.expect(
            contract: executing.contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        ContractTest.expect(
            contract: executing.contract,
            state: .resolved(20),
            timeout: .seconds(1)
        ) {
            contract1.resolve(20)
        }

        ContractTest.expect(
            contract: executing.contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }

        ContractTest.expect(
            contract: executing.contract,
            state: .rejected(ContractTest.SampleError.two),
            timeout: .seconds(1)
        ) {
            contract1.reject(ContractTest.SampleError.two)
        }
        
        ContractTest.expect(
            contract: executing.contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.cancel()
        }
        
        ContractTest.expect(
            contract: executing.contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract1.resolve(10)
        }
    }

    private final class QueueMarker: @unchecked Sendable {
        let key = DispatchSpecificKey<UInt8>()
    }

    private final class DeinitToken: Sendable {
        private let onDeinit: @Sendable () -> Void

        init(onDeinit: @escaping @Sendable () -> Void) {
            self.onDeinit = onDeinit
        }

        deinit {
            onDeinit()
        }
    }
}
