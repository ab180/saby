//
//  ContractMergeTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import XCTest
@testable import SabyConcurrency

final class ContractMergeTest: XCTestCase {
    func test__merge_same_2() {
        let contract0 = Contract<Int, Error>()
        let contract1 = Contract<Int, Error>()
        
        let contract = Contract.merge([contract0, contract1])
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(10),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(20),
            timeout: .seconds(1)
        ) {
            contract1.resolve(20)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.two),
            timeout: .seconds(1)
        ) {
            contract1.reject(ContractTest.SampleError.two)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.cancel()
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract1.resolve(10)
        }
    }
    
    func test__merge_2() {
        let contract0 = Contract<Int, Error>()
        let contract1 = Contract<String, Error>()
        
        let contract = Contract.merge(contract0, contract1)
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(.value0(10)),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(.value1("20")),
            timeout: .seconds(1)
        ) {
            contract1.resolve("20")
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.reject(ContractTest.SampleError.one)
        }

        ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.two),
            timeout: .seconds(1)
        ) {
            contract1.reject(ContractTest.SampleError.two)
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.cancel()
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract1.resolve("10")
        }
    }
    
    func test__never_merge_2() {
        let contract0 = Contract<Int, Never>()
        let contract1 = Contract<String, Never>()
        
        let contract = Contract.merge(contract0, contract1)
        
        ContractTest.expect(
            contract: contract,
            state: .resolved(.value0(10)),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }

        ContractTest.expect(
            contract: contract,
            state: .resolved(.value1("20")),
            timeout: .seconds(1)
        ) {
            contract1.resolve("20")
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.cancel()
        }
        
        ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract1.resolve("10")
        }
    }
}

extension Contract.MergedValue2: Equatable where Value0: Equatable, Value1: Equatable {
    public static func == (
        lhs: Contract.MergedValue2<Value0, Value1>,
        rhs: Contract.MergedValue2<Value0, Value1>
    ) -> Bool {
        if
            case .value0(let leftValue) = lhs,
            case .value0(let rightValue) = rhs
        {
            return leftValue == rightValue
        }
        
        if
            case .value1(let leftValue) = lhs,
            case .value1(let rightValue) = rhs
        {
            return leftValue == rightValue
        }
        
        return false
    }
}
