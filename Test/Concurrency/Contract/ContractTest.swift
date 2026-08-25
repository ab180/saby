//
//  ContractTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/06.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct ContractTest {
    @Test
    func test__repeated_resolve_and_reject_are_delivered_in_order() async {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let values = LockedBox<[String]>([])
        let callbacks = AsyncLatch()

        contract.subscribe(
            on: queue,
            onResolved: { value in
                values.withValue { $0.append("resolve:\(value)") }
                callbacks.signal()
            },
            onRejected: { error in
                values.withValue { $0.append("reject:\(error)") }
                callbacks.signal()
            },
            onCanceled: {}
        )

        contract.resolve(1)
        contract.reject(.one)
        contract.resolve(2)
        contract.reject(.two)
        for _ in 0..<4 {
            #expect(await callbacks.wait(timeout: .seconds(1)))
        }

        #expect(values.value == [
            "resolve:1",
            "reject:one",
            "resolve:2",
            "reject:two",
        ])
    }

    @Test
    func test__cancel_waits_for_prior_events_and_suppresses_later_events() async {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let values = LockedBox<[String]>([])
        let canceled = AsyncLatch()

        contract.subscribe(
            on: queue,
            onResolved: { value in values.withValue { $0.append("resolve:\(value)") } },
            onRejected: { error in values.withValue { $0.append("reject:\(error)") } },
            onCanceled: {
                values.withValue { $0.append("cancel") }
                canceled.signal()
            }
        )

        contract.resolve(1)
        contract.reject(.one)
        contract.cancel()
        contract.resolve(2)
        contract.reject(.two)
        #expect(await canceled.wait(timeout: .seconds(1)))
        queue.sync {}

        #expect(values.value == ["resolve:1", "reject:one", "cancel"])
    }

    @Test
    func test__concurrent_cancel_notifies_each_subscriber_once() async {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let callbackCounts = LockedBox(Array(repeating: 0, count: 32))
        let callbacks = AsyncLatch()

        for index in 0..<32 {
            contract.subscribe(on: queue) {
                callbackCounts.withValue { $0[index] += 1 }
                callbacks.signal()
            }
        }

        DispatchQueue.concurrentPerform(iterations: 1_000) { _ in
            contract.cancel()
        }
        for _ in 0..<32 {
            #expect(await callbacks.wait(timeout: .seconds(1)))
        }

        #expect(callbackCounts.value == Array(repeating: 1, count: 32))
    }

    @Test
    func test__concurrent_subscribe_emit_and_cancel_notifies_every_subscriber_once() async {
        let iterationCount = 256
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function, attributes: .concurrent)
        let callbackCounts = LockedBox(Array(repeating: 0, count: iterationCount))
        let callbacks = AsyncLatch()

        DispatchQueue.concurrentPerform(iterations: iterationCount) { index in
            contract.subscribe(
                on: queue,
                onResolved: { _ in },
                onRejected: { _ in },
                onCanceled: {
                    callbackCounts.withValue { $0[index] += 1 }
                    callbacks.signal()
                }
            )

            switch index % 3 {
            case 0: contract.resolve(index)
            case 1: contract.reject(.one)
            default: contract.cancel()
            }
        }

        contract.cancel()
        #expect(await callbacks.wait(count: iterationCount, timeout: .seconds(5)))
        #expect(
            callbackCounts.value ==
            Array(repeating: 1, count: iterationCount)
        )
    }

    @Test
    func test__late_subscriber_to_canceled_contract_is_notified_on_requested_queue() async {
        let executing = Contract<Int, SampleError>.executing()
        let contract = executing.contract
        let queue = DispatchQueue(label: #function)
        let marker = QueueMarker()
        let callbackMarker = LockedBox<UInt8?>(nil)
        let canceled = AsyncLatch()
        queue.setSpecific(key: marker.key, value: 1)
        executing.cancel()

        contract.subscribe(on: queue) {
            callbackMarker.withValue { $0 = DispatchQueue.getSpecific(key: marker.key) }
            canceled.signal()
        }
        #expect(await canceled.wait(timeout: .seconds(1)))

        #expect(callbackMarker.value == 1)
    }

    @Test
    func test__active_cancel_uses_contract_queue() async {
        let contractQueue = DispatchQueue(label: "\(#function).contract")
        let subscriberQueue = DispatchQueue(label: "\(#function).subscriber")
        let contract = Contract<Int, SampleError>.executing(on: contractQueue).contract
        let marker = QueueMarker()
        let callbackMarker = LockedBox<UInt8?>(nil)
        let canceled = AsyncLatch()
        contractQueue.setSpecific(key: marker.key, value: 1)
        subscriberQueue.setSpecific(key: marker.key, value: 2)

        contract.subscribe(on: subscriberQueue) {
            callbackMarker.withValue { $0 = DispatchQueue.getSpecific(key: marker.key) }
            canceled.signal()
        }
        contract.cancel()
        #expect(await canceled.wait(timeout: .seconds(1)))

        #expect(callbackMarker.value == 1)
    }

    @Test
    func test__callback_can_resolve_reentrantly_without_deadlock() async {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let values = LockedBox<[Int]>([])
        let callbacks = AsyncLatch()

        contract.subscribe(
            on: queue,
            onResolved: { value in
                values.withValue { $0.append(value) }
                if value == 1 {
                    contract.resolve(2)
                }
                callbacks.signal()
            },
            onRejected: { _ in },
            onCanceled: {}
        )

        contract.resolve(1)
        #expect(await callbacks.wait(timeout: .seconds(1)))
        #expect(await callbacks.wait(timeout: .seconds(1)))

        #expect(values.value == [1, 2])
    }

    @Test
    func test__subscriber_deinit_can_reenter_contract_during_cancel() async {
        let contract = Contract<Int, SampleError>()
        let queue = DispatchQueue(label: #function)
        let tokenDeinitialized = AsyncLatch()
        let cancelReturned = AsyncLatch()

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

        #expect(await tokenDeinitialized.wait(timeout: .seconds(1)))
        #expect(await cancelReturned.wait(timeout: .seconds(1)))
    }

    @Test
    func test__executing_deinit_cancels_contract() async {
        let canceled = AsyncLatch()
        weak var weakExecuting: ContractExecuting<Int, SampleError>?

        do {
            let executing = Contract<Int, SampleError>.executing(cancelWhen: .deinit)
            weakExecuting = executing
            executing.contract.subscribe { canceled.signal() }
        }

        #expect(weakExecuting == nil)
        #expect(await canceled.wait(timeout: .seconds(1)))
    }
    
    @Test
    func test__resolve() async {
        let contract = Contract<Int, Error>()
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract.resolve(10)
        }
    }
    
    @Test
    func test__reject() async {
        let contract = Contract<Int, Error>()
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        ) {
            contract.reject(SampleError.one)
        }
    }
    
    @Test
    func test__cancel() async {
        let executing = Contract<Int, Error>.executing()
        let contract = executing.contract
        executing.cancel()
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract.resolve(0)
        }
    }
    
    @Test
    func test__executing_resolve() async {
        let executing = Contract<Int, Error>.executing()
        
        await ContractTest.expect(
            contract: executing.contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            executing.resolve(10)
        }
    }
    
    @Test
    func test__executing_reject() async {
        let executing = Contract<Int, Error>.executing()
        
        await ContractTest.expect(
            contract: executing.contract,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        ) {
            executing.reject(SampleError.one)
        }
    }
    
    @Test
    func test__executing_cancel() async {
        let canceled = AsyncLatch()
        
        let executing = Contract<Int, Error>.executing()

        await ContractTest.expect(
            contract: executing.contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            executing.contract.subscribe {
                canceled.signal()
            }
            executing.contract.cancel()
        }

        #expect(await canceled.wait(timeout: .seconds(1)))
    }
    
    @Test
    func test__executing_subscribe() async {
        let executing = Contract<Int, Error>.executing()
        let contract0 = Contract<Int, Error>()
        let contract1 = Contract<Int, Error>()
        
        executing.subscribe([contract0, contract1])
        
        await ContractTest.expect(
            contract: executing.contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: executing.contract,
            state: .resolved(20),
            timeout: .seconds(1)
        ) {
            contract1.resolve(20)
        }

        await ContractTest.expect(
            contract: executing.contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }

        await ContractTest.expect(
            contract: executing.contract,
            state: .rejected(ContractTest.SampleError.two),
            timeout: .seconds(1)
        ) {
            contract1.reject(ContractTest.SampleError.two)
        }
        
        await ContractTest.expect(
            contract: executing.contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.cancel()
        }
        
        await ContractTest.expect(
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
