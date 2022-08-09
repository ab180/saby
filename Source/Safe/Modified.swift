//
//  Modified.swift
//  SabySafe
//
//  Created by WOF on 2022/08/09.
//

import Foundation

public func modified<Value>(_ value: Value, _ block: (inout Value) -> Void) -> Value {
    var copy = value
    block(&copy)
    return copy
}
