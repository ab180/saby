//
//  PromiseConvert.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/08/25.
//

import Foundation

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func from<
        Result: Sendable,
        ResultFailure: Error & Sendable
    >(
        _ promise: Promise<Result, ResultFailure>?
    ) -> Promise<Result?, ResultFailure> {
        if let promise = promise {
            return promise.toPromiseOptional()
        }
        else {
            return Promise<Result?, ResultFailure>.resolved(nil)
        }
    }
}

extension Promise {
    public func toPromiseOptional() -> Promise<Value?, Failure> {
        let promiseReturn = Promise<Value?, Failure>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public func toPromiseVoid() -> Promise<Void, Failure> {
        let promiseReturn = Promise<Void, Failure>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { _ in promiseReturn.resolve(()) },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public func toPromiseAny() -> Promise<any Sendable, Failure> {
        let promiseReturn = Promise<any Sendable, Failure>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}

extension Promise where Failure == Never {
    public func toPromiseError() -> Promise<Value, Error> {
        let promiseReturn = Promise<Value, Error>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public func toPromiseOptionalError() -> Promise<Value?, Error> {
        let promiseReturn = Promise<Value?, Error>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public func toPromiseVoidError() -> Promise<Void, Error> {
        let promiseReturn = Promise<Void, Error>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { _ in promiseReturn.resolve(()) },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public func toPromiseAnyError() -> Promise<any Sendable, Error> {
        let promiseReturn = Promise<any Sendable, Error>(queue: self.queue)
        
        subscribe(
            on: queue,
            onResolved: { promiseReturn.resolve($0) },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}
