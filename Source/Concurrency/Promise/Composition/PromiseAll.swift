//
//  PromiseAll.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func all<Value0, Failure0>(
        on queue: DispatchQueue = .global(),
        _ promises: [Promise<Value0, Failure0>]
    ) -> Promise<[Value0], Failure0> {
        let promiseReturn = Promise<[Value0], Failure0>(queue: queue)
        let resolve = {
            var values = [Value0]()
            for promise in promises {
                if case .resolved(let value) = promise.state.capture({ $0 }) {
                    values.append(value)
                }
                else {
                    return
                }
            }
            
            promiseReturn.resolve(values)
        }
        
        for promise in promises {
            promise.subscribe(
                queue: promise.queue,
                onResolved: { _ in resolve() },
                onRejected: { promiseReturn.reject($0) },
                onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
            )
        }
        
        if promises.isEmpty {
            resolve()
        }
        
        return promiseReturn
    }
    
    public static func all<each PromiseValue, each PromiseFailure>(
        on queue: DispatchQueue = .global(),
        _ promises: repeat Promise<each PromiseValue, each PromiseFailure>
    ) -> Promise<(repeat each PromiseValue), Error> {
        let promiseReturn = Promise<(repeat each PromiseValue), Error>(queue: queue)
        
        let resolve = {
            let captures = (repeat (each promises).state.capture({ $0 }))
            
            for capture in repeat each captures {
                guard case .resolved = capture
                else { return }
            }
            
            let resolved = (repeat (each captures).resolved!)
            promiseReturn.resolve(resolved)
        }
        
        for promise in repeat each promises {
            promise.subscribe(
                queue: queue,
                onResolved: { _ in resolve() },
                onRejected: { promiseReturn.reject($0) },
                onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
            )
        }
        
        return promiseReturn
    }
}

extension PromiseState {
    fileprivate var resolved: Value? {
        guard case .resolved(let value) = self else { return nil }
        return value
    }
}
