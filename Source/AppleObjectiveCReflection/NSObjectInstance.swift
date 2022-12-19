//
//  NSObjectInstance.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/23.
//

import Foundation

extension NSObjectClass {
    public func instance(object: Any?) -> NSObjectInstance? {
        NSObjectInstance(anyClass: anyClass, object: object)
    }
}

public final class NSObjectInstance {
    let object: NSObject
    
    fileprivate init?(anyClass: AnyClass, object: Any?) {
        guard
            let object = object as? NSObject,
            object.isKind(of: anyClass)
        else {
            return nil
        }
        
        self.object = object
    }
}
