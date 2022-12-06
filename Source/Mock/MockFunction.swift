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
        _ type: ((Argument) -> Result).Type,
        _ implementation: @escaping (Argument) -> Result
    ) {
        self.implementation = implementation
        self.calls = []
    }
    
    public init(
        _ type: ((Argument) -> Result).Type,
        _ result: Result
    ) {
        self.init(type) { _ in result }
    }
    
    public init(
        _ type: ((Argument) -> Result).Type
    )
    where
        Result == Void
    {
        self.init(type) { _ in }
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
        argument: Argument? = nil,
        result: Result? = nil
    ) -> Bool
    where
        Argument: Equatable,
        Result: Equatable
    {
        let argument = { () -> ((Argument) -> Bool)? in
            guard let argument else { return nil }
            return { $0 == argument }
        }()
        
        let result = { () -> ((Result) -> Bool)? in
            guard let result else { return nil }
            return { $0 == result }
        }()
        
        return isCalled(
            at: at,
            argument: argument,
            result: result
        )
    }
}
