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
    public static func all<
        ElementValue: Sendable,
        ElementFailure: Error & Sendable
    >(
        on queue: DispatchQueue = .global(),
        _ promises: [Promise<ElementValue, ElementFailure>]
    ) -> Promise<[ElementValue], ElementFailure> {
        let promiseReturn = Promise<[ElementValue], ElementFailure>(queue: queue)
        let resolve: @Sendable () -> Void = {
            let values = promises.compactMap { $0.capture().resolved }
            guard values.count == promises.count else { return }

            promiseReturn.resolve(values)
        }
        
        for promise in promises {
            promise.subscribe(
                on: promise.queue,
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
    
    @_documentation(visibility: internal)
    public static func all<each PromiseValue: Sendable>(
        on queue: DispatchQueue = .global(),
        _ promises: repeat Promise<each PromiseValue, Never>
    ) -> Promise<(repeat each PromiseValue), Never> {
        let promiseReturn = Promise<(repeat each PromiseValue), Never>(queue: queue)
        
        let resolve: @Sendable () -> Void = {
            let captures = (repeat (each promises).capture().resolved)

            for capture in repeat each captures {
                guard capture != nil else { return }
            }

            let resolved = (repeat (each captures)!)
            promiseReturn.resolve(resolved)
        }
        
        for promise in repeat each promises {
            promise.subscribe(
                on: queue,
                onResolved: { _ in resolve() },
                onRejected: { _ in },
                onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
            )
        }
        
        return promiseReturn
    }
    
    @_documentation(visibility: internal)
    public static func tryAll<
        each PromiseValue: Sendable,
        each PromiseFailure: Error & Sendable
    >(
        on queue: DispatchQueue = .global(),
        _ promises: repeat Promise<each PromiseValue, each PromiseFailure>
    ) -> Promise<(repeat each PromiseValue), Error> {
        let promiseReturn = Promise<(repeat each PromiseValue), Error>(queue: queue)
        
        let resolve: @Sendable () -> Void = {
            let captures = (repeat (each promises).capture().resolved)

            for capture in repeat each captures {
                guard capture != nil else { return }
            }

            let resolved = (repeat (each captures)!)
            promiseReturn.resolve(resolved)
        }
        
        for promise in repeat each promises {
            promise.subscribe(
                on: queue,
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
