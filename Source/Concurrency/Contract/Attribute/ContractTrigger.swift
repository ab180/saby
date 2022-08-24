//
//  ContractTrigger.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/18.
//

import Foundation

extension Contract {
    public func trigger<AnyValue>(when promise: Promise<AnyValue>) -> Contract<Value> {
        let contract = Contract<Value>(on: queue)
        
        let promiseAtomic = Atomic(Promise<Void>(on: queue) { promise.toPromiseVoid() })
        
        subscribe(subscriber: Subscriber(
            promiseAtomic: promiseAtomic,
            onResolved: { value in contract.resolve(value) },
            onRejected: { error in contract.reject(error) }
        ))
        
        return contract
    }
}
