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
    
    public static func all<Value0, Value1, Failure0, Failure1>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Failure0>,
        _ promise1: Promise<Value1, Failure1>
    ) -> Promise<(Value0, Value1), Error> {
        let promiseReturn = Promise<(Value0, Value1), Error>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1))
        }
        
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Failure0, Failure1, Failure2>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Failure0>,
        _ promise1: Promise<Value1, Failure1>,
        _ promise2: Promise<Value2, Failure2>
    ) -> Promise<(Value0, Value1, Value2), Error> {
        let promiseReturn = Promise<(Value0, Value1, Value2), Error>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2))
        }
        
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3, Failure0, Failure1, Failure2, Failure3>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Failure0>,
        _ promise1: Promise<Value1, Failure1>,
        _ promise2: Promise<Value2, Failure2>,
        _ promise3: Promise<Value3, Failure3>
    ) -> Promise<(Value0, Value1, Value2, Value3), Error> {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3), Error>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 }),
                case .resolved(let value3) = promise3.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3))
        }
        
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3, Value4, Failure0, Failure1, Failure2, Failure3, Failure4>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Failure0>,
        _ promise1: Promise<Value1, Failure1>,
        _ promise2: Promise<Value2, Failure2>,
        _ promise3: Promise<Value3, Failure3>,
        _ promise4: Promise<Value4, Failure4>
    ) -> Promise<(Value0, Value1, Value2, Value3, Value4), Error> {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3, Value4), Error>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 }),
                case .resolved(let value3) = promise3.state.capture({ $0 }),
                case .resolved(let value4) = promise4.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3, value4))
        }
        
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise4.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { promiseReturn.reject($0) },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}

extension Promise where
    Value == Never,
    Failure == Never
{
    public static func all<Value0, Value1>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Never>,
        _ promise1: Promise<Value1, Never>
    ) -> Promise<(Value0, Value1), Never> {
        let promiseReturn = Promise<(Value0, Value1), Never>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1))
        }
        
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Never>,
        _ promise1: Promise<Value1, Never>,
        _ promise2: Promise<Value2, Never>
    ) -> Promise<(Value0, Value1, Value2), Never> {
        let promiseReturn = Promise<(Value0, Value1, Value2), Never>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2))
        }

        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Never>,
        _ promise1: Promise<Value1, Never>,
        _ promise2: Promise<Value2, Never>,
        _ promise3: Promise<Value3, Never>
    ) -> Promise<(Value0, Value1, Value2, Value3), Never> {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3), Never>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 }),
                case .resolved(let value3) = promise3.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3))
        }
        
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3, Value4>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Never>,
        _ promise1: Promise<Value1, Never>,
        _ promise2: Promise<Value2, Never>,
        _ promise3: Promise<Value3, Never>,
        _ promise4: Promise<Value4, Never>
    ) -> Promise<(Value0, Value1, Value2, Value3, Value4), Never> {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3, Value4), Never>(queue: queue)
        let resolve = {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 }),
                case .resolved(let value3) = promise3.state.capture({ $0 }),
                case .resolved(let value4) = promise4.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3, value4))
        }
        
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        promise4.subscribe(
            queue: queue,
            onResolved: { _ in resolve() },
            onRejected: { _ in },
            onCanceled: { [weak promiseReturn] in promiseReturn?.cancel() }
        )
        
        return promiseReturn
    }
}
