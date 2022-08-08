//
//  Opt.swift
//  SabySafe
//
//  Created by 0xwof on 2022/08/08.
//

import Foundation

public func opt<Value>(_ type: Value.Type, _ value: Any?) -> Value? {
    return value as? Value
}

public func opt<Value>(_ type: Value?.Type, _ value: Any?) -> Value? {
    return value as? Value
}
