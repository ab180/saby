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

/// Class method of NSObject
/// 1. Class: use Any or ActualType (Example: NSString\*)
/// 2. Value: use ActualType (Using Any can lead crash) (Example: int)
/// 3. Pointer: use OpaquePointer (Using Any can lead crash) (Example: NSError\*\*)
/// ```swift
/// let result = {
///     let function = unsafeBitCast(
///         classMethod.implementation,
///         to: (@convention(c)(AnyClass, Selector, ...)->...).self
///     )
///     return function(
///         classMethod.anyClass,
///         classMethod.selector,
///         ...
///     )
/// }()
/// ```
public final class NSObjectClassMethod {
    public let anyClass: AnyClass
    public let selector: Selector
    public let implementation: IMP
    
    fileprivate init?(anyClass: AnyClass, name: String) {
        let selector = NSSelectorFromString(name)
        guard let method = class_getClassMethod(anyClass, selector) else { return nil }
        let implementation = method_getImplementation(method)
        
        self.anyClass = anyClass
        self.selector = selector
        self.implementation = implementation
    }
}

#endif
