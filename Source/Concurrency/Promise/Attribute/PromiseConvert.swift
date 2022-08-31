//
//  PromiseConvert.swift
//  SabyConcurrency
//
//  Created by WOF on 2022/08/25.
//

import Foundation

extension Promise {
    public static func from(
        _ promise: Promise<Value>?
    ) -> Promise<Value?> {
        if let promise = promise {
            return promise.toPromiseOptional()
        }
        else {
            return Promise<Value?>.resolved(nil)
        }
    }
}

extension Promise {
    public func toPromiseOptional() -> Promise<Value?> {
        self.then { $0 }
    }
    
    public func toPromiseVoid() -> Promise<Void> {
        self.then { _ in }
    }
    
    public func toPromiseAny() -> Promise<Any> {
        self.then { $0 }
    }
}
