//
//  Compute.swift
//  SabySafe
//
//  Created by WOF on 2022/08/08.
//

import Foundation

public func compute<Result>(
    _ block: () -> Result
) -> Result {
    return block()
}

public func compute<Value, Result>(
    _ type: Value.Type,
    _ value: Any?,
    _ block: (Value) -> Result
) -> Result? {
    if let value = value as? Value {
        return block(value)
    } else {
        return nil
    }
}

public func compute<Value, Result>(
    _ type: Value.Type,
    _ value: Any?,
    _ block: (Value) -> Result?
) -> Result? {
    if let value = value as? Value {
        return block(value)
    } else {
        return nil
    }
}
