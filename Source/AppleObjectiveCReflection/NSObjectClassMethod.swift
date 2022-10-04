//
//  NSObjectClassMethod.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/23.
//

import Foundation

extension NSObject.Class {
    public func method(name: String) -> NSObject.ClassMethod? {
        NSObject.ClassMethod(anyClass: anyClass, name: name)
    }
}

extension NSObject {
    public final class ClassMethod {
        let anyClass: AnyClass
        let selector: Selector
        let method: Method
        
        fileprivate init?(anyClass: AnyClass, name: String) {
            let selector = NSSelectorFromString(name)
            guard let method = class_getClassMethod(anyClass, selector) else { return nil }
            
            self.anyClass = anyClass
            self.selector = selector
            self.method = method
        }
    }
}

extension NSObject.Class {
    @discardableResult
    public func call(
        _ classMethod: NSObject.ClassMethod
    ) -> Any? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        typealias Function = @convention(c)(AnyClass, Selector)->Any?
        let implementation = method_getImplementation(classMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(anyClass, classMethod.selector)
    }
    
    @discardableResult
    public func call(
        _ classMethod: NSObject.ClassMethod,
        with argument0: Any?
    ) -> Any? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        typealias Function = @convention(c)(AnyClass, Selector, Any?)->Any?
        let implementation = method_getImplementation(classMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(anyClass, classMethod.selector, argument0)
    }
    
    @discardableResult
    public func call(
        _ classMethod: NSObject.ClassMethod,
        with argument0: Any?,
        with argument1: Any?
    ) -> Any? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?)->Any?
        let implementation = method_getImplementation(classMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(anyClass, classMethod.selector, argument0, argument1)
    }
    
    @discardableResult
    public func call(
        _ classMethod: NSObject.ClassMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?
    ) -> Any? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?)->Any?
        let implementation = method_getImplementation(classMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(anyClass, classMethod.selector, argument0, argument1, argument2)
    }
    
    @discardableResult
    public func call(
        _ classMethod: NSObject.ClassMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?
    ) -> Any? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?)->Any?
        let implementation = method_getImplementation(classMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3)
    }
    
    @discardableResult
    public func call(
        _ classMethod: NSObject.ClassMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?,
        with argument4: Any?
    ) -> Any? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?, Any?)->Any?
        let implementation = method_getImplementation(classMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3, argument4)
    }
}
