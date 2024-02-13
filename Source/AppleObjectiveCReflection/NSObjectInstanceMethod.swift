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

/// Instance method of NSObject
/// 1. Class: use Any or ActualType (Example: NSString\*)
/// 2. Value: use ActualType (Using Any can lead crash) (Example: int)
/// 3. Pointer: use OpaquePointer (Using Any can lead crash) (Example: NSError\*\*)
/// ```swift
/// let result = {
///     let function = unsafeBitCast(
///         method.implementation,
///         to: (@convention(c)(NSObject, Selector, ...)->...).self
///     )
///     return function(
///         method.object,
///         method.selector,
///         ...
///     )
/// }()
/// ```
public final class NSObjectInstanceMethod {
    public let object: NSObject
    public let selector: Selector
    public let implementation: Method
    
    fileprivate init?(object: NSObject, name: String) {
        let selector = NSSelectorFromString(name)
        guard let method = class_getInstanceMethod(type(of: object), selector) else { return nil }
        let implementation = method_getImplementation(method)
        
        self.object = object
        self.selector = selector
        self.implementation = implementation
    }
}

#endif
