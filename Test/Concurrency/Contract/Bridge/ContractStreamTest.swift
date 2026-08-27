//
//  ContractStreamTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2026/08/27.
//

import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct ContractStreamTest {
    @Test
    func test__stream_yields_events_in_order_and_finishes_on_cancel() async {
        let contract = Contract<Int, SampleError>()
        let stream = contract.stream

        contract.resolve(1)
        contract.reject(.one)
        contract.resolve(2)
        contract.cancel()

        var events: [String] = []
        for await event in stream {
            switch event {
            case .success(let value): events.append("resolve:\(value)")
            case .failure(let error): events.append("reject:\(error)")
            }
        }

        #expect(events == ["resolve:1", "reject:one", "resolve:2"])
    }

    @Test
    func test__stream_from_canceled_contract_finishes() async {
        let contract = Contract<Int, SampleError>()
        contract.cancel()

        var iterator = contract.stream.makeAsyncIterator()

        #expect(await iterator.next() == nil)
    }
}

private extension ContractStreamTest {
    enum SampleError: Error { case one }
}
