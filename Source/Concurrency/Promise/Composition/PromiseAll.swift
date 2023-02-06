//
//  PromiseAll.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {    
    public static func all<Value0>(
        on queue: DispatchQueue = .global(),
        _ promises: [Promise<Value0>]
    ) -> Promise<[Value0]> where Value == Void
    {
        let promiseReturn = Promise<[Value0]>(queue: queue)
        let group = DispatchGroup()
        
        promises.forEach { promise in
            group.enter()
            promise.subscribe(
                on: promise.queue,
                onResolved: { _ in group.leave() },
                onRejected: { promiseReturn.reject($0); group.leave() },
                onCanceled: { promiseReturn.cancel(); group.leave() }
            )
        }
        
        group.notify(queue: queue) {
            var values = [Value0]()
            promises.forEach { promise in
                if case .resolved(let value) = promise.state {
                    values.append(value)
                }
            }

            if values.count != promises.count {
                return
            }
            
            promiseReturn.resolve(values)
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0>,
        _ promise1: Promise<Value1>
    ) -> Promise<(Value0, Value1)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1)>(queue: queue)
        let group = DispatchGroup()
        
        group.enter()
        promise0.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state,
                case .resolved(let value1) = promise1.state
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0>,
        _ promise1: Promise<Value1>,
        _ promise2: Promise<Value2>
    ) -> Promise<(Value0, Value1, Value2)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1, Value2)>(queue: queue)
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state,
                case .resolved(let value1) = promise1.state,
                case .resolved(let value2) = promise2.state
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0>,
        _ promise1: Promise<Value1>,
        _ promise2: Promise<Value2>,
        _ promise3: Promise<Value3>
    ) -> Promise<(Value0, Value1, Value2, Value3)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3)>(queue: queue)
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise3.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state,
                case .resolved(let value1) = promise1.state,
                case .resolved(let value2) = promise2.state,
                case .resolved(let value3) = promise3.state
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3, Value4>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0>,
        _ promise1: Promise<Value1>,
        _ promise2: Promise<Value2>,
        _ promise3: Promise<Value3>,
        _ promise4: Promise<Value4>
    ) -> Promise<(Value0, Value1, Value2, Value3, Value4)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3, Value4)>(queue: queue)
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise3.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise4.subscribe(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state,
                case .resolved(let value1) = promise1.state,
                case .resolved(let value2) = promise2.state,
                case .resolved(let value3) = promise3.state,
                case .resolved(let value4) = promise4.state
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3, value4))
        }
        
        return promiseReturn
    }
}
