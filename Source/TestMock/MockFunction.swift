//
//  MockFunction.swift
//  SabyTestMock
//
//  Created by WOF on 2022/12/06.
//

import Foundation

import SabyConcurrency

public final class MockFunction<Argument, Result> {
    public var implementation: (Argument) -> Result {
        didSet {
            if mode == .expect {
                expect = nil
                mode = .implementation
            }
        }
    }
    public var expect: Result! {
        didSet {
            if mode == .implementation {
                implementation = { _ in self.expect }
                mode = .expect
            }
        }
    }
    public var calls: [MockFunctionCall<Argument, Result>]
    var mode: Mode = .implementation
    
    init(
        implementation: @escaping (Argument) -> Result,
        calls: [MockFunctionCall<Argument, Result>]
    ) {
        self.implementation = implementation
        self.calls = calls
    }
}

extension MockFunction {
    enum Mode {
        case implementation
        case expect
    }
}

extension MockFunction {
    public convenience init(
        _ original: (Argument) -> Result = { _ in
            fatalError()
        },
        implementation: @escaping (Argument) -> Result
    ) {
        self.init(
            implementation: implementation,
            calls: []
        )
    }
    
    public convenience init(
        _ original: (Argument) -> Result = { _ in
            fatalError()
        },
        expect: Result
    ) {
        self.init(original) { _ in expect }
        self.expect = expect
    }
    
    public convenience init(
        _ original: (Argument) -> Result = { _ in
            fatalError()
        }
    ) {
        let implementation: (Argument) -> Result = { _ in
            fatalError("no implementation")
        }
        
        if let resultType = Result.self as? Mockable.Type {
            let expect = resultType.mock() as! Result
            self.init(original, implementation: implementation)
            self.expect = expect
        }
        else if Result.self is Void.Type {
            let expect = () as! Result
            self.init(original, implementation: implementation)
            self.expect = expect
        }
        else if Result.self is Promise<Void, Never>.Type {
            let expect = Promise<Void, Never>.resolved(()) as! Result
            self.init(original, implementation: implementation)
            self.expect = expect
        }
        else if Result.self is Promise<Void, Error>.Type {
            let expect = Promise<Void, Error>.resolved(()) as! Result
            self.init(original, implementation: implementation)
            self.expect = expect
        }
        else {
            self.init(original, implementation: implementation)
        }
    }
}

extension MockFunction {
    public func callAsFunction(_ argument: Argument) -> Result {
        let result = implementation(argument)
        calls.append(MockFunctionCall(argument: argument, result: result))
        
        return result
    }
}

public struct MockFunctionCall<Argument, Result> {
    public let argument: Argument
    public let result: Result
}

extension MockFunction {
    public func isCalled(
        at: Int? = nil,
        argument: ((Argument) -> Bool)? = nil,
        result: ((Result) -> Bool)? = nil
    ) -> Bool {
        let isMatch = { (
            call: MockFunctionCall<Argument, Result>
        ) -> Bool in
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
