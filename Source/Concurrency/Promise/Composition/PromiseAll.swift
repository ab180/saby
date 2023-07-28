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
        let group = DispatchGroup()
        
        promises.forEach { promise in
            group.enter()
            promise.subscribe(
                queue: promise.queue,
                onResolved: { _ in group.leave() },
                onRejected: { promiseReturn.reject($0); group.leave() },
                onCanceled: { promiseReturn.cancel(); group.leave() }
            )
        }
        
        group.notify(queue: queue) {
            var values = [Value0]()
            promises.forEach { promise in
                if case .resolved(let value) = promise.state.capture({ $0 }) {
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
    
    public static func all<Value0, Value1, Failure0, Failure1>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Failure0>,
        _ promise1: Promise<Value1, Failure1>
    ) -> Promise<(Value0, Value1), Error> {
        let promiseReturn = Promise<(Value0, Value1), Error>(queue: queue)
        let group = DispatchGroup()
        
        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Failure0, Failure1, Failure2>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Failure0>,
        _ promise1: Promise<Value1, Failure1>,
        _ promise2: Promise<Value2, Failure2>
    ) -> Promise<(Value0, Value1, Value2), Error> {
        let promiseReturn = Promise<(Value0, Value1, Value2), Error>(queue: queue)
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2))
        }
        
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
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
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
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise4.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
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
        let group = DispatchGroup()
        
        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2>(
        on queue: DispatchQueue = .global(),
        _ promise0: Promise<Value0, Never>,
        _ promise1: Promise<Value1, Never>,
        _ promise2: Promise<Value2, Never>
    ) -> Promise<(Value0, Value1, Value2), Never> {
        let promiseReturn = Promise<(Value0, Value1, Value2), Never>(queue: queue)
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
            guard
                case .resolved(let value0) = promise0.state.capture({ $0 }),
                case .resolved(let value1) = promise1.state.capture({ $0 }),
                case .resolved(let value2) = promise2.state.capture({ $0 })
            else {
                return
            }
            
            promiseReturn.resolve((value0, value1, value2))
        }
        
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
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
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
        let group = DispatchGroup()

        group.enter()
        promise0.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise1.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise2.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise3.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        group.enter()
        promise4.subscribe(
            queue: queue,
            onResolved: { _ in group.leave() },
            onRejected: { _ in },
            onCanceled: { promiseReturn.cancel(); group.leave() }
        )
        
        group.notify(queue: queue) {
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
        
        return promiseReturn
    }
}
