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
    _ value: Value,
    _ block: (Value) -> Result
) -> Result {
    return block(value)
}

public func compute<Value, Result>(
    _ option: ComputeOption.NonNull,
    _ value: Value?,
    _ block: (Value) -> Result
) -> Result? {
    if let value = value {
        return block(value)
    } else {
        return nil
    }
}

public func compute<Value, Result>(
    _ option: ComputeOption.NonNull,
    _ value: Value?,
    _ block: (Value) -> Result?
) -> Result? {
    if let value = value {
        return block(value)
    } else {
        return nil
    }
}

public func compute<Value, Result>(
    _ option: ComputeOption.`Type`<Value>,
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
    _ option: ComputeOption.`Type`<Value>,
    _ value: Any?,
    _ block: (Value) -> Result?
) -> Result? {
    if let value = value as? Value {
        return block(value)
    } else {
        return nil
    }
}

public enum ComputeOption {
    public enum `Type`<Value> {
        case type(Value.Type)
    }
    public enum NonNull {
        case nonNull
    }
}
