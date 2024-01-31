//
//  NSObjectInstanceMethod.swift
//  SabyAppleObjectiveCReflection
//
//  Created by WOF on 2022/08/23.
//

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

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
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ instanceMethod: NSObjectInstanceMethod,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard object == instanceMethod.object else { return nil }
        
        let implementation = method_getImplementation(instanceMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(NSObject, Selector)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(NSObject, Selector)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(NSObject, Selector)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, instanceMethod.selector)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard object == instanceMethod.object else { return nil }
        
        let implementation = method_getImplementation(instanceMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(NSObject, Selector, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(NSObject, Selector, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(NSObject, Selector, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, instanceMethod.selector, argument0)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard object == instanceMethod.object else { return nil }
        
        let implementation = method_getImplementation(instanceMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, instanceMethod.selector, argument0, argument1)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard object == instanceMethod.object else { return nil }
        
        let implementation = method_getImplementation(instanceMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1, argument2)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1, argument2)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, instanceMethod.selector, argument0, argument1, argument2)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard object == instanceMethod.object else { return nil }
        
        let implementation = method_getImplementation(instanceMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1, argument2, argument3)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1, argument2, argument3)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, instanceMethod.selector, argument0, argument1, argument2, argument3)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ instanceMethod: NSObjectInstanceMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?,
        with argument4: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard object == instanceMethod.object else { return nil }
        
        let implementation = method_getImplementation(instanceMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1, argument2, argument3, argument4)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(object, instanceMethod.selector, argument0, argument1, argument2, argument3, argument4)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(NSObject, Selector, Any?, Any?, Any?, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, instanceMethod.selector, argument0, argument1, argument2, argument3, argument4)
            return () as? Return
        }
    }
}

extension NSObjectInstance {
    private func cast<Actual>(
        _ value: Unmanaged<AnyObject>,
        to type: Actual.Type
    ) -> Actual {
        let raw = unsafeBitCast(value, to: Int.self)
        
        switch MemoryLayout<Actual>.size {
        case 1:
            return unsafeBitCast(Int8(raw), to: type)
        case 2:
            return unsafeBitCast(Int16(raw), to: type)
        case 4:
            return unsafeBitCast(Int32(raw), to: type)
        default:
            return unsafeBitCast(Int64(raw), to: type)
        }
    }
}

#endif
