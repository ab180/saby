//
//  JSONAccess.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/12.
//

import Foundation

extension JSON {
    public subscript(keys: [AccessKey]) -> JSON? {
        get {
            keys.reduce(self as JSON?) { result, key in
                guard let result = result else { return nil }
                switch key {
                case .string(let key): return result[ifObject: key]
                case .int(let key): return result[ifArray: key]
                }
            }
        }
        set(value) {
            var value = value ?? .null
            var results: [JSON] = [self]
            
            for key in keys.dropLast() {
                guard
                    let last = results.last,
                    let result = last[key]
                else { return }
                results.append(result)
            }
            
            for key in keys.reversed() {
                guard var last = results.popLast() else { return }
                last[key] = value
                value = last
            }
            
            self = value
        }
    }
    
    public subscript(keys: AccessKey...) -> JSON? {
        get {
            return self[keys]
        }
        set(value) {
            self[keys] = value
        }
    }
    
    public subscript(key: AccessKey) -> JSON? {
        get {
            switch key {
            case .string(let key): return self[ifObject: key]
            case .int(let key): return self[ifArray: key]
            }
        }
        set(value) {
            switch key {
            case .string(let key): self[ifObject: key] = value
            case .int(let key): self[ifArray: key] = value
            }
        }
    }
    
    public subscript(ifObject key: String) -> JSON? {
        get {
            guard case .object(let object) = self else { return nil }
            return object[key]
        }
        set(value) {
            guard case .object(var object) = self else { return }
            object[key] = value ?? .null
            self = .object(object)
        }
    }
    
    public subscript(ifArray index: Int) -> JSON? {
        get {
            guard case .array(let array) = self else { return nil }
            guard 0 <= index, index < array.endIndex else { return nil }
            return array[index]
        }
        set(value) {
            guard case .array(var array) = self else { return }
            guard 0 <= index, index < array.endIndex else { return }
            array[index] = value ?? .null
            self = .array(array)
        }
    }
}

extension JSON {
    public mutating func delete(_ key: AccessKey) -> Void {
        switch key {
        case .string(let key): delete(ifObject: key)
        case .int(let key): delete(ifArray: key)
        }
    }
    
    public mutating func delete(ifObject key: String) -> Void {
        guard case .object(var object) = self else { return }
        object.removeValue(forKey: key)
        self = .object(object)
    }
    
    public mutating func delete(ifArray index: Int) -> Void {
        guard case .array(var array) = self else { return }
        guard 0 <= index, index < array.endIndex else { return }
        array.remove(at: index)
        self = .array(array)
    }
    
    public mutating func push(_ value: JSON) -> Void {
        guard case .array(var array) = self else { return }
        array.append(value)
        self = .array(array)
    }
    
    public mutating func push(ifArray value: JSON) -> Void {
        guard case .array(var array) = self else { return }
        array.append(value)
        self = .array(array)
    }
}

extension JSON {
    public enum AccessKey {
        case int(Int)
        case string(String)
    }
}

extension JSON.AccessKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension JSON.AccessKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}
