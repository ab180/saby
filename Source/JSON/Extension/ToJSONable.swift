//
//  ToJSONable.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/15.
//

import Foundation

public protocol ToJSONable {
    func toJSON() -> JSON
}

extension String: ToJSONable {
    public func toJSON() -> JSON { .string(self) }
}

extension Double: ToJSONable {
    public func toJSON() -> JSON { .number(self) }
}

extension Float: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension Int64: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension Int32: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension Int16: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension Int8: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension Int: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension UInt64: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension UInt32: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension UInt16: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension UInt8: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension UInt: ToJSONable {
    public func toJSON() -> JSON { .number(Double(self)) }
}

extension Bool: ToJSONable {
    public func toJSON() -> JSON { .boolean(self) }
}

extension Dictionary: ToJSONable where Key == String, Value == ToJSONable? {
    public func toJSON() -> JSON { .object(self.mapValues { $0?.toJSON() ?? .null }) }
}

extension Array: ToJSONable where Element == ToJSONable? {
    public func toJSON() -> JSON { .array(self.map { $0?.toJSON() ?? .null }) }
}

extension JSON {
    public static func from(_ value: ToJSONable) -> JSON {
        value.toJSON()
    }
    
    public static func from(_ value: ToJSONable?) -> JSON {
        value?.toJSON() ?? .null
    }
}
