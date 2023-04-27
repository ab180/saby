//
//  NSObjectClassMethod.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

import Foundation

extension NSObjectClass {
    public func method(name: String) -> NSObjectClassMethod? {
        NSObjectClassMethod(anyClass: anyClass, name: name)
    }
}

public final class NSObjectClassMethod {
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

extension NSObjectClass {
    @discardableResult
    public func call(
        _ classMethod: NSObjectClassMethod
    ) -> Any? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        typealias Function = @convention(c)(AnyClass, Selector)->Any?
        let implementation = method_getImplementation(classMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(anyClass, classMethod.selector)
    }
    
    @discardableResult
    public func call(
        _ classMethod: NSObjectClassMethod,
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
        _ classMethod: NSObjectClassMethod,
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
        _ classMethod: NSObjectClassMethod,
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
        _ classMethod: NSObjectClassMethod,
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
        _ classMethod: NSObjectClassMethod,
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

#endif
