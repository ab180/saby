//
//  PromiseRecover.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/12/20.
//

import Foundation

extension Promise {
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) throws -> Value
    ) -> Promise<Value, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: {
                do {
                    let value = try block($0)
                    promiseReturn.resolve(value)
                } catch let error {
                    promiseReturn.reject(error)
                }
            },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    @discardableResult
    public func recover<ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) throws -> Promise<Value, ResultFailure>
    ) -> Promise<Value, Error> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Error>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { [weak self] in
                do {
                    let promise = try block($0)
                    promise.subscribe(
                        queue: queue,
                        onResolved: { promiseReturn.resolve($0) },
                        onRejected: { promiseReturn.reject($0) },
                        onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
                    )
                    self?.subscribe(
                        queue: queue,
                        onCanceled: { [weak promise] in promise?.cancel() }
                    )
                } catch let error {
                    promiseReturn.reject(error)
                }
            },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}

extension Promise {
    @discardableResult
    public func recover(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) -> Value
    ) -> Promise<Value, Never> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, Never>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: {
                let value = block($0)
                promiseReturn.resolve(value)
            },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    @discardableResult
    public func recover<ResultFailure>(
        on queue: DispatchQueue? = nil,
        _ block: @escaping (Failure) -> Promise<Value, ResultFailure>
    ) -> Promise<Value, ResultFailure> {
        let queue = queue ?? self.queue
        
        let promiseReturn = Promise<Value, ResultFailure>(queue: self.queue)
        
        subscribe(
            queue: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { [weak self] in
                let promise = block($0)
                promise.subscribe(
                    queue: queue,
                    onResolved: { promiseReturn.resolve($0) },
                    onRejected: { promiseReturn.reject($0) },
                    onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
                )
                self?.subscribe(
                    queue: queue,
                    onCanceled: { [weak promise] in promise?.cancel() }
                )
            },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}
