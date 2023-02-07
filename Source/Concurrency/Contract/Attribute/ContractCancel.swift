//
//  ContractCancel.swift
//  SabyConcurrency
//
//  Created by WOF on 2023/02/06.
//

import Foundation

extension Contract {
    public static func cancel<AnyValue>(
        on queue: DispatchQueue = .global(),
        when promise: Promise<AnyValue>,
        block: () -> Contract<Value>
    ) -> Contract<Value> {
        let contract = block()
        
        promise.subscribe(
            on: queue,
            onResolved: { _ in contract.cancel() },
            onRejected: { _ in },
            onCanceled: {}
        )
        
        return contract
    }
}
