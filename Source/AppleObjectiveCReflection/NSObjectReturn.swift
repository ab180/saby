//
//  NSObjectReturn.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2024/01/31.
//

import Foundation

public enum NSObjectReturn<Actual> {
    case reference(Actual.Type)
    case value(Actual.Type)
    case void(Actual.Type)
}

extension NSObjectReturn where Actual == Any {
    public static let reference = NSObjectReturn.reference(Any.self)
}

extension NSObjectReturn where Actual == Void {
    public static let void = NSObjectReturn.void(Void.self)
}
