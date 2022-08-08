//
//  Check.swift
//  SabySafe
//
//  Created by 0xwof on 2022/08/08.
//

import Foundation

public func check<Value>(_ type: Value.Type, _ value: Any?) -> Bool {
    return value is Value
}
