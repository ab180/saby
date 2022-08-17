//
//  Require.swift
//  SabySafe
//
//  Created by WOF on 2022/08/08.
//

import Foundation

public func require<Value>(_ type: Value.Type, _ value: Any?) throws -> Value {
    return try (value as? Value) ?? throwing(RequireError.notRequiredType)
}

public func require<Value>(_ value: Value?) throws -> Value {
    return try value ?? throwing(RequireError.notNonNullType)
}

public enum RequireError: Error {
    case notRequiredType
    case notNonNullType
}
