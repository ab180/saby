//
//  JSONExpression.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/12.
//

import Foundation

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral values: (String, JSON)...) {
        self = .object([String: JSON](uniqueKeysWithValues: values))
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral values: JSON...) {
        self = .array(values)
    }
}
