//
//  NSObjectClass.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/22.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation

public final class NSObjectClass {
    let anyClass: AnyClass
    
    public init?(name: String) {
        guard let anyClass = NSClassFromString(name) else { return nil }
        
        self.anyClass = anyClass
    }
}

#endif
