//
//  ContractMerge.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/18.
//

import Foundation

extension Contract {
    public static func merge<Value0>(
        on queue: DispatchQueue = .global(),
        _ contracts: [Contract<Value0>]
    ) -> Contract<Value0> where Value == Void
    {
        let contract = Contract<Value0>(queue: queue)
        
        contracts.forEach {
            $0.subscribe(
                queue: queue,
                onResolved: { value0 in contract.resolve(value0) },
                onRejected: { error in contract.reject(error) },
                onCanceled: { contract.cancel() }
            )
        }
        
        return contract
    }
    
    public static func merge<Value0, Value1>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0>,
        _ contract1: Contract<Value1>
    ) -> Contract<MergedValue2<Value0, Value1>> where Value == Void
    {
        let contract = Contract<MergedValue2<Value0, Value1>>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public static func merge<Value0, Value1, Value2>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0>,
        _ contract1: Contract<Value1>,
        _ contract2: Contract<Value2>
    ) -> Contract<MergedValue3<Value0, Value1, Value2>> where Value == Void
    {
        let contract = Contract<MergedValue3<Value0, Value1, Value2>>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract2.subscribe(
            queue: queue,
            onResolved: { value2 in contract.resolve(.value2(value2)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public static func merge<Value0, Value1, Value2, Value3>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0>,
        _ contract1: Contract<Value1>,
        _ contract2: Contract<Value2>,
        _ contract3: Contract<Value3>
    ) -> Contract<MergedValue4<Value0, Value1, Value2, Value3>> where Value == Void
    {
        let contract = Contract<MergedValue4<Value0, Value1, Value2, Value3>>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract2.subscribe(
            queue: queue,
            onResolved: { value2 in contract.resolve(.value2(value2)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract3.subscribe(
            queue: queue,
            onResolved: { value3 in contract.resolve(.value3(value3)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public static func merge<Value0, Value1, Value2, Value3, Value4>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0>,
        _ contract1: Contract<Value1>,
        _ contract2: Contract<Value2>,
        _ contract3: Contract<Value3>,
        _ contract4: Contract<Value4>
    ) -> Contract<MergedValue5<Value0, Value1, Value2, Value3, Value4>> where Value == Void
    {
        let contract = Contract<MergedValue5<Value0, Value1, Value2, Value3, Value4>>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract2.subscribe(
            queue: queue,
            onResolved: { value2 in contract.resolve(.value2(value2)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract3.subscribe(
            queue: queue,
            onResolved: { value3 in contract.resolve(.value3(value3)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        contract4.subscribe(
            queue: queue,
            onResolved: { value4 in contract.resolve(.value4(value4)) },
            onRejected: { error in contract.reject(error) },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
}

extension Contract {
    public enum MergedValue2<Value0, Value1> {
        case value0(Value0)
        case value1(Value1)
    }
    
    public enum MergedValue3<Value0, Value1, Value2> {
        case value0(Value0)
        case value1(Value1)
        case value2(Value2)
    }
    
    public enum MergedValue4<Value0, Value1, Value2, Value3> {
        case value0(Value0)
        case value1(Value1)
        case value2(Value2)
        case value3(Value3)
    }
    
    public enum MergedValue5<Value0, Value1, Value2, Value3, Value4> {
        case value0(Value0)
        case value1(Value1)
        case value2(Value2)
        case value3(Value3)
        case value4(Value4)
    }
}
