//
//  NSObjectGlobal.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2023/04/27.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation

public final class NSObjectGlobal {
    private init() {}
    
    public static func variable<Variable>(type: Variable.Type, name: String) -> Variable? {
        dlsym(
            UnsafeMutableRawPointer(bitPattern: -2),
            name
        )?.load(as: type)
    }
}

#endif
