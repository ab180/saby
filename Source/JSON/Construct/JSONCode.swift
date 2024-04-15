//
//  JSONCode.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/12.
//

import Foundation

extension JSON: Encodable, Decodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .boolean(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .null: try container.encodeNil()
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .number(value)
        }
        else if let value = try? container.decode(Float.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(Int64.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(Int32.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(Int16.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(Int8.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(Int.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(UInt64.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(UInt32.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(UInt16.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(UInt8.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(UInt.self) {
            self = .number(Double(value))
        }
        else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        }
        else if let value = try? container.decode(String.self) {
            self = .string(value)
        }
        else if let value = try? container.decode([String: JSON].self) {
            self = .object(value)
        }
        else if let value = try? container.decode([JSON].self) {
            self = .array(value)
        }
        else if container.decodeNil() {
            self = .null
        }
        else {
            throw InternalError.decodedValueIsNotJSON
        }
    }
}
