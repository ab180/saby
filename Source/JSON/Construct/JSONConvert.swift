//
//  JSONConvert.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/12.
//

import Foundation

extension JSON {
    public static func parse(_ string: String) throws -> JSON {
        guard let data = string.data(using: .utf8) else { throw InternalError.stringToDataIsNil }
        return try JSON.parse(data)
    }
    
    public static func parse(_ data: Data) throws -> JSON {
        let value = try JSONDecoder().decode(JSON.self, from: data)
        return value
    }
    
    public func stringify(format: JSONEncoder.OutputFormatting = []) throws -> String {
        let data = try datafy(format: format)
        guard let string = String(data: data, encoding: .utf8) else { throw InternalError.dataToStringIsNil }
        return string
    }
    
    public func datafy(format: JSONEncoder.OutputFormatting = []) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = format
        let data = try encoder.encode(self.deepFilterNonConfirmingFloat())
        return data
    }
}

extension JSON {
    public static func encode<Value: Encodable>(_ value: Value) throws -> JSON {
        let encoder = JSONEncoder.acceptingNonConfirmingFloat()
        let decoder = JSONDecoder.acceptingNonConfirmingFloat()
        let data = try encoder.encode(value)
        let value = try decoder.decode(JSON.self, from: data)
        return value
    }
    
    public func decode<Value: Decodable>(_ type: Value.Type) throws -> Value {
        let encoder = JSONEncoder.acceptingNonConfirmingFloat()
        let decoder = JSONDecoder.acceptingNonConfirmingFloat()
        let data = try encoder.encode(self)
        let value = try decoder.decode(type, from: data)
        return value
    }
}

extension JSON {
    private func deepFilterNonConfirmingFloat() throws -> JSON {
        return try self.deepFilter {
            if case .number(let value) = $0 {
                if !value.isNaN && !value.isInfinite {
                    return true
                }
                else {
                    return false
                }
            }
            return true
        } ?? { throw InternalError.valueIsNotJSON }()
    }
}

extension JSON {
    public static func from(unsafe value: Any?) throws -> JSON {
        if let value = value as? Double, !value.isNaN, !value.isInfinite {
            return .number(value)
        }
        else if let value = value as? Float, !value.isNaN, !value.isInfinite {
            return .number(Double(value))
        }
        else if let value = value as? Int64 {
            return .number(Double(value))
        }
        else if let value = value as? Int32 {
            return .number(Double(value))
        }
        else if let value = value as? Int16 {
            return .number(Double(value))
        }
        else if let value = value as? Int8 {
            return .number(Double(value))
        }
        else if let value = value as? Int {
            return .number(Double(value))
        }
        else if let value = value as? UInt64 {
            return .number(Double(value))
        }
        else if let value = value as? UInt32 {
            return .number(Double(value))
        }
        else if let value = value as? UInt16 {
            return .number(Double(value))
        }
        else if let value = value as? UInt8 {
            return .number(Double(value))
        }
        else if let value = value as? UInt {
            return .number(Double(value))
        }
        else if let value = value as? Bool {
            return .boolean(value)
        }
        else if let value = value as? String {
            return .string(value)
        }
        else if let value = value as? [String: Any?] {
            return JSON.from(unsafe: value)
        }
        else if let value = value as? [AnyHashable: Any?] {
            return JSON.from(unsafe: value)
        }
        else if let value = value as? [Any?] {
            return JSON.from(unsafe: value)
        }
        else if value == nil {
            return .null
        }
        else {
            throw InternalError.valueIsNotJSON
        }
    }
    
    public static func from(unsafe value: [String: Any]) -> JSON {
        .object(value.compactMapValues { try? JSON.from(unsafe: $0) })
    }
    
    public static func from(unsafe value: [String: Any?]) -> JSON {
        .object(value.compactMapValues { try? JSON.from(unsafe: $0) })
    }
    
    public static func from(unsafe value: [AnyHashable: Any]) -> JSON {
        .object(Dictionary(
            value.compactMap { key, value in
                guard
                    let key = key as? String,
                    let value = try? JSON.from(unsafe: value)
                else {
                    return nil
                }
                return (key, value)
            },
            uniquingKeysWith: { first, last in last }
        ))
    }
    
    public static func from(unsafe value: [AnyHashable: Any?]) -> JSON {
        .object(Dictionary(
            value.compactMap { key, value in
                guard
                    let key = key as? String,
                    let value = try? JSON.from(unsafe: value)
                else {
                    return nil
                }
                return (key, value)
            },
            uniquingKeysWith: { first, last in last }
        ))
    }
    
    public static func from(unsafe value: [Any]) -> JSON {
        .array(value.compactMap { try? JSON.from(unsafe: $0) })
    }
    
    public static func from(unsafe value: [Any?]) -> JSON {
        .array(value.compactMap { try? JSON.from(unsafe: $0) })
    }
}
