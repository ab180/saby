//
//  JSON.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/12.
//

import Foundation

extension JSON {
    public var rawString: String? {
        guard case .string(let value) = self else { return nil }
        return value
    }
    
    public var rawNumber: Double? {
        guard case .number(let value) = self else { return nil }
        return value
    }
    
    public var rawBoolean: Bool? {
        guard case .boolean(let value) = self else { return nil }
        return value
    }
    
    public var rawObject: [String: JSON]? {
        guard case .object(let value) = self else { return nil }
        return value
    }
    
    public var rawArray: [JSON]? {
        guard case .array(let value) = self else { return nil }
        return value
    }
    
    public var raw: Any? {
        if case .string(let value) = self { return value }
        if case .number(let value) = self { return value }
        if case .boolean(let value) = self { return value }
        if case .object(let value) = self {
            return value.mapValues { $0.raw }
        }
        if case .array(let value) = self {
            return value.map { $0.raw }
        }
        return nil
    }
}

extension JSON {
    public var isString: Bool {
        guard case .string(_) = self else { return false }
        return true
    }
    
    public var isNumber: Bool {
        guard case .number(_) = self else { return false }
        return true
    }
    
    public var isBoolean: Bool {
        guard case .boolean(_) = self else { return false }
        return true
    }
    
    public var isObject: Bool {
        guard case .object(_) = self else { return false }
        return true
    }
    
    public var isArray: Bool {
        guard case .array(_) = self else { return false }
        return true
    }
    
    public var isNull: Bool {
        guard case .null = self else { return false }
        return true
    }
}
