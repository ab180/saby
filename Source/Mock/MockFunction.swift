//
//  MockFunction.swift
//  SabyMock
//
//  Created by WOF on 2022/12/06.
//

import Foundation

public struct MockFunction<Argument, Result> {
    public var implementation: (Argument) -> Result
    public var calls: [Call]
    
    public init(
        _ original: (Argument) -> Result
            = { _ in fatalError() },
        implementation: @escaping (Argument) -> Result
            = { _ in
                if Result.self is Void.Type { return () as! Result }
                fatalError("no implementation")
            }
    ) {
        self.implementation = implementation
        self.calls = []
    }
    
    public init(
        _ original: (Argument) -> Result
            = { _ in fatalError() },
        result: Result
    ) {
        self.init(original) { _ in result }
    }
    
    public mutating func callAsFunction(_ argument: Argument) -> Result {
        let result = implementation(argument)
        calls.append(Call(argument: argument, result: result))
        
        return result
    }
}

extension MockFunction {
    public struct Call {
        let argument: Argument
        let result: Result
    }
}

extension MockFunction {
    public func isCalled(
        at: Int? = nil,
        argument: ((Argument) -> Bool)? = nil,
        result: ((Result) -> Bool)? = nil
    ) -> Bool {
        let isMatch = { (call: Call) -> Bool in
            if let argument, !argument(call.argument) {
                return false
            }
            
            if let result, !result(call.result) {
                return false
            }
            
            return true
        }
        
        if calls.isEmpty {
            return false
        }
        
        guard let at else {
            return calls.first { isMatch($0) } != nil
        }
        
        if calls.count <= at {
            return false
        }
        
        return isMatch(calls[at])
    }
    
    public func isCalled(
        at: Int? = nil,
        argument: Argument,
        result: Result
    ) -> Bool
    where
        Argument: Equatable,
        Result: Equatable
    {
        isCalled(
            at: at,
            argument: { $0 == argument },
            result: { $0 == result }
        )
    }
    
    public func isCalled(
        at: Int? = nil,
        argument: Argument
    ) -> Bool
    where
        Argument: Equatable
    {
        isCalled(
            at: at,
            argument: { $0 == argument }
        )
    }
    
    public func isCalled(
        at: Int? = nil,
        result: Result
    ) -> Bool
    where
        Result: Equatable
    {
        isCalled(
            at: at,
            result: { $0 == result }
        )
    }
}
