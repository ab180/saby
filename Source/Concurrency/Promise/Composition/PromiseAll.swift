//
//  PromiseAll.swift
//  SabyConcurrency
//
//  Created by WOF on 2020/04/02.
//

import Foundation

extension Promise {    
    public static func all<Value0>(
        on queue: DispatchQueue = Setting.defaultQueue,
        _ promises: [Promise<Value0>]
    ) -> Promise<[Value0]> where Value == Void
    {
        let promiseReturn = Promise<[Value0]>(queue: queue)
        let group = DispatchGroup()
        
        promises.forEach { promise in
            group.enter()
            promise.subscribe(subscriber: Promise<Value0>.Subscriber(
                on: promise.queue,
                onResolved: { _ in group.leave() },
                onRejected: { promiseReturn.reject($0); group.leave() }
            ))
        }
        
        group.notify(queue: queue) {
            var values = [Value0]()
            promises.forEach { promise in
                if case .resolved(let value) = promise.state {
                    values.append(value)
                }
            }

            if values.count != promises.count {
                promiseReturn.reject(InternalError.resultOfAllHasWrongType)
                return
            }
            
            promiseReturn.resolve(values)
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1>(
        on queue: DispatchQueue = Setting.defaultQueue,
        @AllBuilder builder: () -> (Promise<Value0>, Promise<Value1>)
    ) -> Promise<(Value0, Value1)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1)>(queue: queue)
        let group = DispatchGroup()
        
        let promises = builder()
        
        group.enter()
        promises.0.subscribe(subscriber: Promise<Value0>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.1.subscribe(subscriber: Promise<Value1>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        
        group.notify(queue: queue) {
            guard case .resolved(let value0) = promises.0.state,
                  case .resolved(let value1) = promises.1.state else
            {
                promiseReturn.reject(InternalError.resultOfAllHasWrongType)
                return
            }
            
            promiseReturn.resolve((value0, value1))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2>(
        on queue: DispatchQueue = Setting.defaultQueue,
        @AllBuilder builder: () -> (Promise<Value0>, Promise<Value1>, Promise<Value2>)
    ) -> Promise<(Value0, Value1, Value2)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1, Value2)>(queue: queue)
        let group = DispatchGroup()
        
        let promises = builder()

        group.enter()
        promises.0.subscribe(subscriber: Promise<Value0>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.1.subscribe(subscriber: Promise<Value1>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.2.subscribe(subscriber: Promise<Value2>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        
        group.notify(queue: queue) {
            guard case .resolved(let value0) = promises.0.state,
                  case .resolved(let value1) = promises.1.state,
                  case .resolved(let value2) = promises.2.state else
            {
                promiseReturn.reject(InternalError.resultOfAllHasWrongType)
                return
            }
            
            promiseReturn.resolve((value0, value1, value2))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3>(
        on queue: DispatchQueue = Setting.defaultQueue,
        @AllBuilder builder: () -> (Promise<Value0>, Promise<Value1>, Promise<Value2>, Promise<Value3>)
    ) -> Promise<(Value0, Value1, Value2, Value3)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3)>(queue: queue)
        let group = DispatchGroup()
        
        let promises = builder()

        group.enter()
        promises.0.subscribe(subscriber: Promise<Value0>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.1.subscribe(subscriber: Promise<Value1>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.2.subscribe(subscriber: Promise<Value2>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.3.subscribe(subscriber: Promise<Value3>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        
        group.notify(queue: queue) {
            guard case .resolved(let value0) = promises.0.state,
                  case .resolved(let value1) = promises.1.state,
                  case .resolved(let value2) = promises.2.state,
                  case .resolved(let value3) = promises.3.state else
            {
                promiseReturn.reject(InternalError.resultOfAllHasWrongType)
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3))
        }
        
        return promiseReturn
    }
    
    public static func all<Value0, Value1, Value2, Value3, Value4>(
        on queue: DispatchQueue = Setting.defaultQueue,
        @AllBuilder builder: () -> (Promise<Value0>, Promise<Value1>, Promise<Value2>, Promise<Value3>, Promise<Value4>)
    ) -> Promise<(Value0, Value1, Value2, Value3, Value4)> where Value == Void
    {
        let promiseReturn = Promise<(Value0, Value1, Value2, Value3, Value4)>(queue: queue)
        let group = DispatchGroup()
        
        let promises = builder()

        group.enter()
        promises.0.subscribe(subscriber: Promise<Value0>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.1.subscribe(subscriber: Promise<Value1>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.2.subscribe(subscriber: Promise<Value2>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.3.subscribe(subscriber: Promise<Value3>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        group.enter()
        promises.4.subscribe(subscriber: Promise<Value4>.Subscriber(
            on: queue,
            onResolved: { _ in group.leave() },
            onRejected: { promiseReturn.reject($0); group.leave() }
        ))
        
        group.notify(queue: queue) {
            guard case .resolved(let value0) = promises.0.state,
                  case .resolved(let value1) = promises.1.state,
                  case .resolved(let value2) = promises.2.state,
                  case .resolved(let value3) = promises.3.state,
                  case .resolved(let value4) = promises.4.state else
            {
                promiseReturn.reject(InternalError.resultOfAllHasWrongType)
                return
            }
            
            promiseReturn.resolve((value0, value1, value2, value3, value4))
        }
        
        return promiseReturn
    }
    
    @resultBuilder
    public struct AllBuilder {
        public static func buildBlock<Value0, Value1>(
            _ promise0: Promise<Value0>,
            _ promise1: Promise<Value1>
        ) -> (Promise<Value0>, Promise<Value1>)
        {
            (promise0, promise1)
        }
        
        public static func buildBlock<Value0, Value1, Value2>(
            _ promise0: Promise<Value0>,
            _ promise1: Promise<Value1>,
            _ promise2: Promise<Value2>
        ) -> (Promise<Value0>, Promise<Value1>, Promise<Value2>)
        {
            (promise0, promise1, promise2)
        }
        
        public static func buildBlock<Value0, Value1, Value2, Value3>(
            _ promise0: Promise<Value0>,
            _ promise1: Promise<Value1>,
            _ promise2: Promise<Value2>,
            _ promise3: Promise<Value3>
        ) -> (Promise<Value0>, Promise<Value1>, Promise<Value2>, Promise<Value3>)
        {
            (promise0, promise1, promise2, promise3)
        }
        
        public static func buildBlock<Value0, Value1, Value2, Value3, Value4>(
            _ promise0: Promise<Value0>,
            _ promise1: Promise<Value1>,
            _ promise2: Promise<Value2>,
            _ promise3: Promise<Value3>,
            _ promise4: Promise<Value4>
        ) -> (Promise<Value0>, Promise<Value1>, Promise<Value2>, Promise<Value3>, Promise<Value4>)
        {
            (promise0, promise1, promise2, promise3, promise4)
        }
    }
}
