//
//  NSObjectInstance.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/23.
//

import Foundation

extension NSObject.Class {
    public func instance(object: Any?) -> NSObject.Instance? {
        NSObject.Instance(anyClass: anyClass, object: object)
    }
}

extension NSObject {
    public final class Instance {
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
}
