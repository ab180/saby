//
//  NSObjectInstanceMethod.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/23.
//

import Foundation

extension NSObjectInstance {
    public func method(name: String) -> NSObjectInstanceMethod? {
        NSObjectInstanceMethod(object: object, name: name)
    }
}

public final class NSObjectInstanceMethod {
    let object: NSObject
    let selector: Selector
    let method: Method
    
    fileprivate init?(object: NSObject, name: String) {
        let selector = NSSelectorFromString(name)
        guard let method = class_getInstanceMethod(type(of: object), selector) else { return nil }
        
        self.object = object
        self.selector = selector
        self.method = method
    }
}

extension NSObjectInstance {
    @discardableResult
    public func call(
        _ instanceMethod: NSObjectInstanceMethod
    ) -> Any? {
        guard object == instanceMethod.object else { return nil }
        
        typealias Function = @convention(c)(NSObject, Selector)->Any?
        let implementation = method_getImplementation(instanceMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(object, instanceMethod.selector)
    }
    
    @discardableResult
    public func call(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?
    ) -> Any? {
        guard object == instanceMethod.object else { return nil }
        
        typealias Function = @convention(c)(NSObject, Selector, Any?)->Any?
        let implementation = method_getImplementation(instanceMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(object, instanceMethod.selector, argument0)
    }
    
    @discardableResult
    public func call(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?
    ) -> Any? {
        guard object == instanceMethod.object else { return nil }
        
        typealias Function = @convention(c)(NSObject, Selector, Any?, Any?)->Any?
        let implementation = method_getImplementation(instanceMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(object, instanceMethod.selector, argument0, argument1)
    }
    
    @discardableResult
    public func call(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?
    ) -> Any? {
        guard object == instanceMethod.object else { return nil }
        
        typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?)->Any?
        let implementation = method_getImplementation(instanceMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(object, instanceMethod.selector, argument0, argument1, argument2)
    }
    
    @discardableResult
    public func call(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?
    ) -> Any? {
        guard object == instanceMethod.object else { return nil }
        
        typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?)->Any?
        let implementation = method_getImplementation(instanceMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(object, instanceMethod.selector, argument0, argument1, argument2, argument3)
    }
    
    @discardableResult
    public func call(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?,
        with argument4: Any?
    ) -> Any? {
        guard object == instanceMethod.object else { return nil }
        
        typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?, Any?)->Any?
        let implementation = method_getImplementation(instanceMethod.method)
        let function = unsafeBitCast(implementation, to: Function.self)
        
        return function(object, instanceMethod.selector, argument0, argument1, argument2, argument3, argument4)
    }
}
