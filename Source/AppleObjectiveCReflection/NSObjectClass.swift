//
//  NSObjectClass.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/22.
//

import Foundation

extension NSObject {
    public final class Class {
        let anyClass: AnyClass
        
        public init?(name: String) {
            guard let anyClass = NSClassFromString(name) else { return nil }
            
            self.anyClass = anyClass
        }
    }
}
