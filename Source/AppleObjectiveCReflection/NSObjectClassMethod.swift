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
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ classMethod: NSObjectClassMethod,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        let implementation = method_getImplementation(classMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(AnyClass, Selector)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(AnyClass, Selector)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(AnyClass, Selector)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(anyClass, classMethod.selector)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ classMethod: NSObjectClassMethod,
        with argument0: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        let implementation = method_getImplementation(classMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(AnyClass, Selector, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(AnyClass, Selector, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(AnyClass, Selector, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(anyClass, classMethod.selector, argument0)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ classMethod: NSObjectClassMethod,
        with argument0: Any?,
        with argument1: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        let implementation = method_getImplementation(classMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(anyClass, classMethod.selector, argument0, argument1)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ classMethod: NSObjectClassMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        let implementation = method_getImplementation(classMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1, argument2)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1, argument2)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(anyClass, classMethod.selector, argument0, argument1, argument2)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ classMethod: NSObjectClassMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        let implementation = method_getImplementation(classMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3)
            return () as? Return
        }
    }
    
    /// Call class method with reflection
    @discardableResult
    public func call<Return>(
        _ classMethod: NSObjectClassMethod,
        with argument0: Any?,
        with argument1: Any?,
        with argument2: Any?,
        with argument3: Any?,
        with argument4: Any?,
        return: NSObjectReturn<Return> = .void
    ) -> Return? {
        guard anyClass == classMethod.anyClass else { return nil }
        
        let implementation = method_getImplementation(classMethod.method)
        
        switch `return` {
        case .reference:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?, Any?)->Any?
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3, argument4)
            return result as? Return
        case .value(let type):
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?, Any?)->Unmanaged<AnyObject>
            let function = unsafeBitCast(implementation, to: Function.self)
            let result = function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3, argument4)
            return cast(result, to: type)
        case .void:
            typealias Function = @convention(c)(AnyClass, Selector, Any?, Any?, Any?, Any?, Any?)->Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(anyClass, classMethod.selector, argument0, argument1, argument2, argument3, argument4)
            return () as? Return
        }
    }
}

extension NSObjectClass {
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
