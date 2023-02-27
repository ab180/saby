//
//  ContractMerge.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/07/18.
//

import Foundation

extension Contract where
    Value == Void,
    Failure == Never
{
    public static func merge<Value0, Failure0>(
        on queue: DispatchQueue = .global(),
        _ contracts: [Contract<Value0, Failure0>]
    ) -> Contract<Value0, Failure0> {
        let contract = Contract<Value0, Failure0>(queue: queue)
        
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
    
    public static func merge<Value0, Value1, Failure0, Failure1>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Failure0>,
        _ contract1: Contract<Value1, Failure1>
    ) -> Contract<MergedValue2<Value0, Value1>, Error> {
        let contract = Contract<MergedValue2<Value0, Value1>, Error>(queue: queue)
        
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
    
    public static func merge<Value0, Value1, Value2, Failure0, Failure1, Failure2>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Failure0>,
        _ contract1: Contract<Value1, Failure1>,
        _ contract2: Contract<Value2, Failure2>
    ) -> Contract<MergedValue3<Value0, Value1, Value2>, Error> {
        let contract = Contract<MergedValue3<Value0, Value1, Value2>, Error>(queue: queue)
        
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
    
    public static func merge<Value0, Value1, Value2, Value3, Failure0, Failure1, Failure2, Failure3>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Failure0>,
        _ contract1: Contract<Value1, Failure1>,
        _ contract2: Contract<Value2, Failure2>,
        _ contract3: Contract<Value3, Failure3>
    ) -> Contract<MergedValue4<Value0, Value1, Value2, Value3>, Error> {
        let contract = Contract<MergedValue4<Value0, Value1, Value2, Value3>, Error>(queue: queue)
        
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
    
    public static func merge<Value0, Value1, Value2, Value3, Value4, Failure0, Failure1, Failure2, Failure3, Failure4>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Failure0>,
        _ contract1: Contract<Value1, Failure1>,
        _ contract2: Contract<Value2, Failure2>,
        _ contract3: Contract<Value3, Failure3>,
        _ contract4: Contract<Value4, Failure4>
    ) -> Contract<MergedValue5<Value0, Value1, Value2, Value3, Value4>, Error> {
        let contract = Contract<MergedValue5<Value0, Value1, Value2, Value3, Value4>, Error>(queue: queue)
        
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

extension Contract where
    Value == Void,
    Failure == Never
{
    public static func merge<Value0>(
        on queue: DispatchQueue = .global(),
        _ contracts: [Contract<Value0, Never>]
    ) -> Contract<Value0, Never> {
        let contract = Contract<Value0, Never>(queue: queue)
        
        contracts.forEach {
            $0.subscribe(
                queue: queue,
                onResolved: { value0 in contract.resolve(value0) },
                onRejected: { _ in },
                onCanceled: { contract.cancel() }
            )
        }
        
        return contract
    }
    
    public static func merge<Value0, Value1>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Never>,
        _ contract1: Contract<Value1, Never>
    ) -> Contract<MergedValue2<Value0, Value1>, Never> {
        let contract = Contract<MergedValue2<Value0, Value1>, Never>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public static func merge<Value0, Value1, Value2>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Never>,
        _ contract1: Contract<Value1, Never>,
        _ contract2: Contract<Value2, Never>
    ) -> Contract<MergedValue3<Value0, Value1, Value2>, Never> {
        let contract = Contract<MergedValue3<Value0, Value1, Value2>, Never>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract2.subscribe(
            queue: queue,
            onResolved: { value2 in contract.resolve(.value2(value2)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public static func merge<Value0, Value1, Value2, Value3>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Never>,
        _ contract1: Contract<Value1, Never>,
        _ contract2: Contract<Value2, Never>,
        _ contract3: Contract<Value3, Never>
    ) -> Contract<MergedValue4<Value0, Value1, Value2, Value3>, Never> {
        let contract = Contract<MergedValue4<Value0, Value1, Value2, Value3>, Never>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract2.subscribe(
            queue: queue,
            onResolved: { value2 in contract.resolve(.value2(value2)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract3.subscribe(
            queue: queue,
            onResolved: { value3 in contract.resolve(.value3(value3)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        return contract
    }
    
    public static func merge<Value0, Value1, Value2, Value3, Value4>(
        on queue: DispatchQueue = .global(),
        _ contract0: Contract<Value0, Never>,
        _ contract1: Contract<Value1, Never>,
        _ contract2: Contract<Value2, Never>,
        _ contract3: Contract<Value3, Never>,
        _ contract4: Contract<Value4, Never>
    ) -> Contract<MergedValue5<Value0, Value1, Value2, Value3, Value4>, Never> {
        let contract = Contract<MergedValue5<Value0, Value1, Value2, Value3, Value4>, Never>(queue: queue)
        
        contract0.subscribe(
            queue: queue,
            onResolved: { value0 in contract.resolve(.value0(value0)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract1.subscribe(
            queue: queue,
            onResolved: { value1 in contract.resolve(.value1(value1)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract2.subscribe(
            queue: queue,
            onResolved: { value2 in contract.resolve(.value2(value2)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract3.subscribe(
            queue: queue,
            onResolved: { value3 in contract.resolve(.value3(value3)) },
            onRejected: { _ in },
            onCanceled: { contract.cancel() }
        )
        
        contract4.subscribe(
            queue: queue,
            onResolved: { value4 in contract.resolve(.value4(value4)) },
            onRejected: { _ in },
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
