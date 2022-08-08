//
//  Convert.swift
//  SabySafe
//
//  Created by 0xwof on 2022/08/08.
//

import Foundation

public func convert<Value, Result>(
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
